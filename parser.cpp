#include <cstdio>
#include <cstring>

int main() {

	char ch;
	int lev = 0;
	while ((ch = getchar()) != EOF) {

		if (ch == '{') lev++;
		else if (ch == '}') lev--;

		if (ch == ' ' && lev == 0) putchar('\n');
		else if (ch == ',' && lev == 0) putchar('\n');
		else putchar(ch);
	}
}
