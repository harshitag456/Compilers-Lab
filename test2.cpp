int fib(int x)
{
	if(x==1)
	{
		return 1;
	}
	if(x==0)
	{
		return 0;
	}
	int r1 = fib(x - 1);
	int r2 = fib(x - 2);
	int ans = r1 + r2;
	return ans;
}

int main()
{
	int x = 3;
	int res = fib(x);
}