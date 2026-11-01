#define N 45

const int SID = 1230021;

int data[N];
int median, min_v, max_v, swaps;

unsigned int lcg_next(unsigned int x)
{
    return 1664525u * x + 1013904223u;
}

int out_of_order(int a, int b, int desc)
{
    if (desc)
        return a < b;
    return a > b;
}

void generate(void)
{
    unsigned int x = (unsigned int)SID;
    for (int i = 0; i < N; i++) {
        x = lcg_next(x);
        data[i] = (int)((x >> 16) % 1000u);
    }
}

void sort(int desc)
{
    for (int pass = 0; pass < N - 1; pass++)
        for (int j = 0; j < N - 1 - pass; j++)
            if (out_of_order(data[j], data[j + 1], desc)) {
                int t = data[j];
                data[j] = data[j + 1];
                data[j + 1] = t;
                swaps++;
            }
}

void stats(void)
{
    min_v = max_v = data[0];
    for (int i = 1; i < N; i++) {
        if (data[i] < min_v)
            min_v = data[i];
        if (data[i] > max_v)
            max_v = data[i];
    }
    median = data[(N - 1) / 2];
}

int main(void)
{
    generate();
    sort(SID & 1);
    stats();
    return 0;
}
