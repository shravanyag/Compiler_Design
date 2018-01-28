/*
 *  program to display all steps while parsing a given string
 *  for the grammar S -> aSa | aa
 *  and also display a message indicating if it can be parsed or not
 */
#include<stdio.h>
#include<stdlib.h>

struct grammar
{
  int option;     /*1- aSa, 2- aa*/
  int count;      /*number of a's left to count*/
  int visited;    /*if the node had previosly been visited*/
};

struct grammar typedef GRAMMAR;
int n;
GRAMMAR * stack;

void parser(int index);
int safeState(int index);
void display(int index);

int main()
{
  int only_a;
  do {
    /*Menu Diven program for better user usability of the parser*/
    printf("Enter the length of the string or 0 to exit: ");
    scanf("%d", &n);
    if(n == 0)
    {
      printf("EXITING...\n");
      break;
    }
    else if(n % 2 == 0)
    {
      stack = (GRAMMAR *)(malloc((n + 1) * sizeof(GRAMMAR)));
      for(int ix = 0; ix <= n; ++ix)
      {
        stack[ix].visited = 0;
        /*initialize the stack after allocating dynamic heap memory*/
      }
      parser(0);
      if(stack[0].count == 0)
      {
        printf("The given string can be parsed\n");
      }
      else
      {
        printf("The given string cannot be parsed\n");
      }
    }
    else
    {
      printf("The string does not belong to the given grammar\n");
      printf("Since the string contains odd number of a's\n");
      /*reject all input strings with odd characters*/
    }
  }
  while(n !=  0);
  return 0;
}

int safeState(int index)
{
  /*function that checks if a given state is safe*/
  /*
   *safe state is one where the number of a's already parsed is less
   *than or equal to the number of a's encountered in the input
   */
  if(stack[index].count < 0)
    return 0;
  return 1;
}

void parser(int index)
{
  /*
   *function to check if given number of a's can be parsed by given grammar
   *function implements DFS approach by implicitly using stack frames as stack
   */
  if(index == n)
  {
    stack[n].option = 2;
    stack[n].visited = 1;
    stack[n].count = -2;
    //display(index);
    /*base case - recursion ends here*/
  }
  else if(stack[index].visited == 0)
  {
    stack[index].visited = 1;
    stack[index].option = 1;
    stack[index].count = n - index - 1;
    parser(index + 1);
    /*
     *new stack frame is created each time
     *the first case aSa is always tried first
     *since the parser always tries the first option until backtracking
     *in each stack frame the yet to be encountered a's count decreases
     */
  }
  if((stack[index].visited == 1) && (safeState(index) == 0))
  {
    /*backtracking*/
    if(stack[index].option == 1)
    {
      stack[index].option = 2;
      stack[index - 1].count -= 2;
      stack[index].count = n - index - 2;
      stack[index - 1].count -= 1;
      /*
       *trying option 1 - aSa leads to an unsafe state
       *hence option 2 - aa is tried
       */
    }
    else
    {
      stack[index - 1].option = 2;
      stack[index - 1].count -= 1;
      /*
       *when even option 2 - aa fails
       *we change the parent's option hence logically returning false
       *to the parent stack frame
       */
    }
  }
  else
  {
    if(index > 0)
    {
      stack[index - 1].count = stack[index].count - 1;
    }
    /*
     *in case the present stack is a safe state
     *we just add another a to the parent : aS to aSa
     *thus decrementing the a's yet to be encountered
     */
  }
  display(index);
}

void display(int index)
{
  /*
   *function to display contents of all active stack frames
   *depending on what option, either aS or aSa or aa is displayed
   */
  if(index == n)
  {
    for(int i = 0; i < index; ++i)
      printf("aS -> ");
    printf("aSa");
    printf("\n");
    /*
     *special case for index = n
     *since it always fails for both aSa and aa
     *as backtracking begins at this stack frame
     */
  }
  for(int ix = 0; ix <= index; ++ix)
  {
    if(stack[ix].option == 1 && ix != index)
      printf("aS -> ");
    else if(stack[ix].option == 2)
      printf("aa -> ");
    else
      printf("aSa ->");
  }
  printf("\n");
}
