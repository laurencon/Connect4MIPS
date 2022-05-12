#include "iostream"

using namespace std;


int convertytold(int x, int y, int col)
{
	return (y*col)+x;	
}
int checktop_bot(int arr[],int rows, int columns, int x, int y)
{
	
	int cx ,cy;
	for(cx =x,cy = y; cy>=0;cy--)
	{
		if(arr[convertytold(cx,cy,columns)] != arr[convertytold(x,y,columns)]||arr[convertytold(cx,cy,columns)]==0)
		{
			break;
		}
		
	}
	int cx1,cy1;
	for(cx1 =x,cy1 = y; cy1<rows;cy1++)
	{
		if(arr[convertytold(cx1,cy1,columns)] != arr[convertytold(x,y,columns)]||arr[convertytold(cx1,cy1,columns)]==0)
		{
			break;
		}
	}
	return (cy1-cy)-1;
	
} 
int checkleft_right(int arr[],int rows, int columns, int x, int y)
{
	
	int cx ,cy;
	for(cx =x,cy = y; cx>=0;cx--)//left
	{
		if(arr[convertytold(cx,cy,columns)] != arr[convertytold(x,y,columns)]||arr[convertytold(cx,cy,columns)]==0)
		{
			break;
		}
	}
	int cx1,cy1;
	for(cx1 =x,cy1 = y; cx1<columns;cx1++)//right
	{
		if(arr[convertytold(cx1,cy1,columns)] != arr[convertytold(x,y,columns)]||arr[convertytold(cx1,cy1,columns)]==0)
		{
			break;
		}
	}
	return (cx1-cx)-1;
	
}
int checkforwarddiagnol(int arr[],int rows, int columns, int x, int y)
{
	
	int cx ,cy;
	for(cx =x,cy = y; cx>=0&&cy<rows;cx--,cy++)//bottom left
	{
		if(arr[convertytold(cx,cy,columns)] != arr[convertytold(x,y,columns)]||arr[convertytold(cx,cy,columns)]==0)
		{
			break;
		}
	}
	int cx1,cy1;
	for(cx1 =x,cy1 = y; cy1>=0&&cx1<columns;cy1--,cx1++)//topright
	{
		if(arr[convertytold(cx1,cy1,columns)] != arr[convertytold(x,y,columns)]||arr[convertytold(cx1,cy1,columns)]==0)
		{
			break;
		}
	}
	return (cx1-cx)-1;
	
}
int checkbackdiagnol(int arr[],int rows, int columns, int x, int y)
{
	
	int cx ,cy;
	for(cx =x,cy = y; cx<columns&&cy<rows;cx++,cy++)//bottom right
	{
		if(arr[convertytold(cx,cy,columns)] != arr[convertytold(x,y,columns)]||arr[convertytold(cx,cy,columns)]==0)
		{
			break;
		}
	}
	int cx1,cy1;
	for(cx1 =x,cy1 = y; cy1>=0&&cx1>=0;cy1--,cx1--)//top left
	{
		if(arr[convertytold(cx1,cy1,columns)] != arr[convertytold(x,y,columns)]||arr[convertytold(cx1,cy1,columns)]==0)
		{
			break;
		}
	}
	return (cx1-cx)-1;
	
}
bool checkforwin(int arr[],int rows, int columns, int x, int y)
{
	int topbot=checktop_bot(arr,rows,columns,x,y);
	int leftright=checkleft_right(arr,rows,columns,x,y);
	int backdiagnol=checkforwarddiagnol(arr,rows,columns,x,y);
	int forwarddiagnol=checkbackdiagnol(arr,rows,columns,x,y);
	if(topbot==4||leftright==4||backdiagnol==4||forwarddiagnol==4)
	{
		return true;
	}
	else
		return false;


}

int main() {
    int cols=7,rows=6;
    int arr[cols * rows] = {1,1,1,1,0,0,0,
                            0,0,0,0,0,0,0,
                            0,0,0,0,1,0,0,
                            0,0,0,0,1,0,0,
                            0,0,0,1,1,1,0,
                            0,0,0,0,1,0,0};
    
    cout<<checkleft_right(arr,rows,cols,0,0);
	
}