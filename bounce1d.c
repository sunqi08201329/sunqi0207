#include	<stdio.h>
#include <string.h>
#include    <sys/time.h>
#include    <unistd.h>
#include	<curses.h>
#include	<signal.h>


#define	MESSAGE	"● "
#define BLANK   " "

#define LEN 0
#define WIDE (COLS - 2 * LEN)
#define HIGH (LINES - 2 * LEN)

int draw_wall()
{
	int i;

	initscr();
	clear();
	for (i = 0; i < WIDE; i++) 
	{
		move(LEN, i + LEN);
		addstr("■ ");
	}
	for (i = 0; i < HIGH; i++) 
	{
		move(i + LEN, LEN);
		addstr("■ ");
	}
	for (i = 0; i < WIDE; i++) 
	{
		move(LEN + HIGH, i + LEN);
		addstr("■ ");
	}

	//getch();
	endwin();
	return 0;
}
int set_ticker(int n_msecs)
{
	struct itimerval new_timeset;
	long n_sec, n_usecs;

	n_sec = n_msecs / 1000;
	n_usecs = (n_msecs % 1000) * 1000L;

	new_timeset.it_interval.tv_sec = n_sec;	/* set reload  */
	new_timeset.it_interval.tv_usec = n_usecs;	/* new ticker value */
	new_timeset.it_value.tv_sec = n_sec;	/* store this   */
	new_timeset.it_value.tv_usec = n_usecs;	/* and this     */

	return setitimer(ITIMER_REAL, &new_timeset, NULL);
}

int row;			
int col;			
int xdir;			
int ydir;			

int main()
{
	int delay;		
	int ndelay;		
	int c;			
	void move_msg(int);	

	initscr();
	crmode();
	noecho();
	clear();

	row = HIGH/2 + LEN;		
	col = WIDE + LEN - 1;
	xdir = -1;		
	ydir = -1;		
	delay = 200;		
	
	draw_wall();
	move(row, col);
	addstr(MESSAGE);	
	signal(SIGALRM, move_msg);
	set_ticker(delay);

	while (1) {
		ndelay = 0;
		c = getch();
		if (c == 'Q')
			break;
		if (c == ' '){
			xdir = -xdir;
			ydir = -ydir;
		}
		if (c == 'f' && delay > 2)
			ndelay = delay / 2;
		if (c == 's')
			ndelay = delay * 2;
		if (ndelay > 0)
			set_ticker(delay = ndelay);
	}
	endwin();
	return 0;
}

void move_msg(int signum)
{
	signal(SIGALRM, move_msg);	
	move(row, col);
	addstr(BLANK);
	col += xdir;		
	row += ydir;
	move(row, col);		
	addstr(MESSAGE);	
	refresh();		

	if (xdir == -1 && col == 1)
		xdir = 1;
	else if (xdir == 1 && col + strlen(MESSAGE) >= COLS)
		xdir = -1;
	if (ydir == -1 && (row == 1 || row == (LINES - 2)))
		ydir = 1;
	else if (ydir == 1 && row == (LINES - 2))
		ydir = -1;
	else if (ydir == 1 && row + strlen(MESSAGE) >= LINES)
		ydir = -1;
}
