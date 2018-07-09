# python functions to produce a padded message to be used in modelsim testbenches

def create_binary ( input_string ):
    "Takes a string and outputs its binary form"
    A = ''.join(format(ord(x), 'b').zfill(8) for x in input_string)
    return A


def append_bit_1 ( input_string ):
    "Appends the bit 1 to the binary form"
    input_string = input_string + '1'
    return input_string


def append_k_bit ( input_string ):
    if len(input_string) % 512 == 448:
        return input_string
    else:
        while len(input_string) % 512 != 448:
            input_string = input_string + '0'
        return input_string


def append_length_of_message ( input_string ):
    ""
    # Get value
    bin = format(len(input_string),'b')

    # Construct the 64 bit number?
    final_num = ''
    length = 64-len(bin)
    for x in range(length):
        final_num = final_num + '0'

    final_num = final_num + bin

    return final_num

input_string = input()

# Create a binary version of the input string
binary_string = create_binary ( input_string )

# Append '1' bit to the end as per the SHA256 specification
appended_1_bit_string = append_bit_1 ( binary_string )

# Append 'k' bits to allow for len(string) % 512 == 448
appended_k_string = append_k_bit ( appended_1_bit_string )

# Append length of message
length_of_message = append_length_of_message ( binary_string )

# Create final message
final_message = appended_k_string + length_of_message

print(len(final_message)) 

print final_message 


