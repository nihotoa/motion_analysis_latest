function letter = numToAlphabet(num)
alphabet_list = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
if 1 <= num && num <= 26
    letter = alphabet_list(num);
else
    error('input must be in the range of 1 to 26');
end
end