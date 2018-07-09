#include <linux/init.h>
#include <linux/module.h>
#include <asm/io.h>
#include <asm/uaccess.h>
#include <linux/device.h>
#include <linux/platform_device.h>
#include <linux/cdev.h>

#define DRIVER_NAME "SHA256"
#define COMPATIBLE_STRING	"xlnx,sha256-ctrl-axi-1.0"

/* information about kernel module */
MODULE_AUTHOR("Martina Fogliato");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION(DRIVER_NAME ": driver for SHA256 HW accelerator");
MODULE_ALIAS(DRIVER_NAME);

struct resource *res;     // structure used to access resources of hardware device from device tree
unsigned long remap_size; // size of address space of hardware device
void __iomem *base_addr;  // virtual base address of hardware device
static dev_t dev;         // device major/minor numbers
static struct cdev c_dev; // structure used to represent a character device
static struct class *cl;  // structure used to represent a device class

/* called on device open. does nothing. return 0 (no error). */
static int sha256_open(struct inode *inode, struct file *fp)
{
	return 0;
}

/* called on device close. does nothing. return 0 (no error). */
static int sha256_close(struct inode *inode, struct file *fp)
{
	return 0;
}

/* called on device read. read 32 bits at a time */
static ssize_t sha256_read(struct file *fp, char *buf, size_t count, loff_t * f_pos)
{
	uint32_t data; // read data

	rmb(); // memory read barrier

	data = ioread32(base_addr + *f_pos);
	if(copy_to_user(buf,&data,sizeof(uint32_t))) // copy read data to user space
	{
		return -EACCES; // if error return -EACCES error code
	}
	return sizeof(uint32_t); // return number of read bytes
}

/*called on device write. writes 32 bits at a time */
static ssize_t sha256_write(struct file *fp, const char __user *buf, size_t count, loff_t * f_pos){

	uint32_t data;
	

	if(count != 4){
		return -EFAULT;
	}

	if (copy_from_user(&data, buf, count)){
		return -EFAULT;
	}

	iowrite32(data, base_addr + *f_pos);

	wmb();
    return sizeof(uint32_t);
}


/* supported file operations */
static const struct file_operations sha256_operations = {
	.owner = THIS_MODULE,
	.open = sha256_open,
	.release = sha256_close,
	.read = sha256_read,
	.write = sha256_write
};

/* called when removing module */
static int sha256_remove(struct platform_device *pdev)
{
	device_destroy(cl, dev);                    // remove device from class
	class_destroy(cl);                          // delete class
	cdev_del(&c_dev);                           // delete cdev structure
	unregister_chrdev_region(dev,1);            // unregister device major number
	iounmap(base_addr);                         // unmap base address
	release_mem_region(res->start, remap_size); // deallocate physical address space
  printk(KERN_INFO DRIVER_NAME " module removed.\n");
	return 0;
}

/* called when module linked to kernel */
static int sha256_probe(struct platform_device *pdev)
{
	int ret = 0;            // return values (error code), 0=no error
	struct device *dev_ret; // structure representing device

	/* get information about the memory ressources from device tree */
	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if(!res) {
		dev_err(&pdev->dev, "no memory ressource found\n");
		return -ENODEV;
	}

  /* try to allocate physical address space of device */
	remap_size = res->end - res->start + 1;
	if(!request_mem_region(res->start, remap_size, pdev->name)) {
		dev_err(&pdev->dev, "could not reserve IO address range\n");
		return -ENXIO;
	}

  /* remap allocated physical address space to virtual address space */
	base_addr = ioremap(res->start, remap_size);
	if (base_addr == NULL) {
		dev_err(&pdev->dev, "could not ioremap memory at 0x%08lx\n", (unsigned long)res->start);
		ret = -ENOMEM;
		goto err_release_region;
	}

	if((ret = alloc_chrdev_region(&dev, 0, 1, "sha256"))) // request device major number
	{
		dev_err(&pdev->dev, "could not allocate device major number\n");
		goto err_unmap;
	}

	cdev_init(&c_dev, &sha256_operations);    // initialize cdev structure
	
	if((ret = cdev_add(&c_dev, dev, 1)) < 0) // register cdev structure to kernel, with device major number dev
	{
		dev_err(&pdev->dev, "couldn't add the cdev structure\n");
		goto err_unregister;
	}

	if(IS_ERR(cl = class_create(THIS_MODULE, "sha256"))) // create device class
	{
		dev_err(&pdev->dev, "could not create device class\n");
		goto err_delete_cdev;
	}

	if(IS_ERR(dev_ret = device_create(cl, NULL, dev, NULL, "sha256"))) // populate device info under class
	{
		dev_err(&pdev->dev, "error in device create\n");
		goto err_class_destroy;
	}
	
  printk(KERN_INFO DRIVER_NAME " module loaded.\n");
	printk(KERN_INFO DRIVER_NAME " mapped at virtual address 0x%08lx\n", (unsigned long) base_addr);
	
	return 0;

err_class_destroy:
	class_destroy(cl);
err_delete_cdev:
	cdev_del(&c_dev);
err_unregister:
	unregister_chrdev_region(dev,1);
err_unmap:
	iounmap(base_addr);
err_release_region:
	release_mem_region(res->start, remap_size);
	
	return ret;
}

/* compatible strings of devices driver can work with. last element of list must
 * be empty */
static const struct of_device_id sha256_of_match[] = {
	{.compatible  = COMPATIBLE_STRING},
	{},
};

/* format structure of_device_id */
MODULE_DEVICE_TABLE(of, sha256_of_match);

/* assemble all previously defined functions and structures. will be passed to
 * module_platform_driver macro that registers module to kernel */
static struct platform_driver sha256_drv = {
	.driver = {
		.name = DRIVER_NAME,
		.owner = THIS_MODULE,
		.of_match_table = sha256_of_match},
	.probe = sha256_probe,
	.remove = sha256_remove
};

/* macro used to register module to kernel. creates __init and __exit functions
 * and bind them with module_init() and module_exit() macros */
module_platform_driver(sha256_drv);

