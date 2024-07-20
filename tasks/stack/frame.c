int foobar(int a, int b, int c) {
    int xx = a + 2;                 // xx = 79
    int yy = b + 3;                 // yy = 91
    int zz = c + 4;                 // zz = 103
    int sum = xx + yy + zz;         // sum = 273

    return xx * yy * zz + sum;      // return 740740
}

int main() {
    return foobar(77, 88, 99);
}
