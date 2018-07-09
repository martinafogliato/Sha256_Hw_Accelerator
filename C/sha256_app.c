#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <string.h>

#define BLOCK_BITS 512
#define BLOCK_BYTES 64
#define MAX_BITS 448
#define	WORD_BITS 32
#define WORD_BYTES 4
#define WORDS_IN_BLOCK 16
#define LEN_BITS 64

#define DATA_IN_ADDR 0
#define STATUS_ADDR 4
#define DATA_OUT_ADDR 8

const char msg_last = 8;
const char hash_ack = 4;
const char rst_status = 0;

int main(){
	unsigned char * sha_msg, * sha_msg_or;
    	unsigned int len_max = 64;
    	unsigned int cur_len;
	unsigned int i, j;
	uint32_t num_blocks;
	unsigned char * blocks;
	uint64_t num_bits;
	uint32_t hash[8];
	uint32_t status, data_in;
	uint32_t word_to_send;
    

    int c;
 	FILE * fp = fopen("header.txt", "r");
	if(NULL == fp) {
		perror("header file open\n");
		exit(-1);
	}
 	while ((c = getc(fp)) != EOF){
		putchar(c);
	 }
	fclose(fp);

	int dev = open("/dev/sha256", O_RDWR);
	if(dev < 0) {
		perror("file open\n");
		exit(-1);
	}
	
	puts(">> Author : Martina Fogliato\n>> Eurecom 2018\n>> Digital Systems");

    while(1){
		i = 0;
		cur_len = len_max;
		sha_msg = (char*)malloc(len_max*sizeof(char));
		if(sha_msg == NULL) {
			exit(-1);
		}
		sha_msg_or = sha_msg;
		puts(">> Insert the text to be hashed, press enter to finish : \n");
		
		while (( c = getchar() ) != '\n' && c != EOF){
			sha_msg[i++]=(char)c;
			if(i == cur_len){
        		cur_len += len_max;
				sha_msg = realloc(sha_msg, cur_len);
				if(sha_msg == NULL) {
					perror("malloc");
					exit(-1);
				}
			}
		}

		if(c == '\n' && i == 0) {
			puts(">> Bye bye!");
			free(sha_msg);
			free(blocks);
			close(dev);
			return 0;
		}

		sha_msg[i] = '\0';
		
		//padding

		num_bits = i*8;
		num_blocks = (num_bits + LEN_BITS + 1)/BLOCK_BITS + 1;
		//printf("num_bits = %ld, num_blocks = %d\n", num_bits, num_blocks);
		blocks = malloc(num_blocks * BLOCK_BYTES * sizeof(char));	
		if(blocks == NULL) {
			perror("malloc");
			exit(-1);
		}
		memset(blocks, 0, num_blocks * BLOCK_BYTES * sizeof(char)); 
		memcpy(blocks, sha_msg_or, i);
		blocks[i] = (char)0x80;

		if((pwrite(dev, &rst_status, WORD_BYTES, STATUS_ADDR)) < 4){
			puts("fail to reset status register");
		}
		for(i=0; i<(num_blocks*WORDS_IN_BLOCK-2); i++){
			if((pread(dev, &status, WORD_BYTES, STATUS_ADDR)) < 4) {
				puts("fail to read status register");
			}
			
			//check the device is ready and send one word
			while(0x01 != (status & 0x00000001));
			word_to_send = 0;
			for(j=0; j<4; j++){ 
				//printf("blocks[%d] = %02x\n", j+i*4, blocks[j+i*4]);
				word_to_send |= ((uint32_t)blocks[j+i*4] << (32-8-j*8));
			} 
			//printf("%x\n", word_to_send);
			if((pwrite(dev, &word_to_send, WORD_BYTES, DATA_IN_ADDR))< 4){
				puts("fail to write word");
			}
		}
		word_to_send = 0;
		word_to_send = ((uint32_t*)&num_bits)[1];
				//printf("%x\n", word_to_send);
		 
		if((pread(dev, &status, WORD_BYTES, STATUS_ADDR)) < 4) {
			puts("fail to read status register");
		}
		
		//check the device is ready and send one word
		while(0x01 != (status & 0x00000001));
		if((pwrite(dev, &word_to_send, WORD_BYTES, DATA_IN_ADDR)) < 4){
			printf("fail to write block[%d]\n", i);
		}
		//signal the last word
		if((pwrite(dev, &msg_last, WORD_BYTES, STATUS_ADDR)) < 4){
			puts("fail to set bit 3 of status register");
		}
		//check the device is ready and send the last word
		if((pread(dev, &status, WORD_BYTES, STATUS_ADDR)) < 4) {
			puts("fail to read status register");
		}
		while(0x01 != (status & 0x00000001));
		word_to_send = 0;
		word_to_send = ((uint32_t*)&num_bits)[0];
		//printf("%x\n", word_to_send);
		 
		if((pwrite(dev, &word_to_send, WORD_BYTES, DATA_IN_ADDR)) < 4){
			puts("fail to write word.");
		}
		if((pread(dev, &status, WORD_BYTES, STATUS_ADDR)) < 4) {
			puts("fail to read status register");
		}
		//wait that the hash is valid
		while(0x3 != (status & 0x00000003));
		
		//read the hash words
		for(i=0; i<8; i++){
			if((pread(dev, &hash[i], WORD_BYTES, DATA_OUT_ADDR+i*4)) < 4) {
				puts("fail to read data out register");
			}
		}
		//signal the hash has been read
		if((pwrite(dev, &hash_ack, WORD_BYTES, STATUS_ADDR)) < 4) {
			puts("fail to write bit 4 of status register");
		}

    	printf(">> Hash : ");
		for(i=0; i<8; i++){
			printf("%x ", hash[i]);
		}
		puts("");
		//go back to rst
		if((pwrite(dev, &rst_status, WORD_BYTES, STATUS_ADDR)) < 4){
			puts("fail to reset status register");
		}
		free(sha_msg);
    }
}
