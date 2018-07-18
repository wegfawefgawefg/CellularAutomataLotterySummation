import java.util.Random;

Random randy;

boolean[][] initialCondition;
boolean[][] cells;
boolean[][] newCells;

boolean[] rules;

int divisionFactor = 12;

int horizontalDivisions = 3840 / divisionFactor;//1920 / divisionFactor;
int verticalDivisions = 2160 / divisionFactor;//1080 / divisionFactor;
//int horizontalDivisions = 1920 / divisionFactor;
//int verticalDivisions = 1080 / divisionFactor;

float verticalDivisionHeight;
float horizontalDivisionWidth;

int millisBeforeEachNewLayer = 1;

boolean pause = false;

void setup()
{
  fullScreen( P2D, 1 );
  //size( 800, 500, P2D );
  frameRate( 1000 );

  randy = new Random();

  verticalDivisionHeight = ((float)height) / ((float)verticalDivisions);
  horizontalDivisionWidth = ((float)width) / ((float)horizontalDivisions);

  
  initialCondition = new boolean[verticalDivisions][horizontalDivisions];
  newCells = new boolean[verticalDivisions][horizontalDivisions];
  cells = new boolean[verticalDivisions][horizontalDivisions];
  randomizeInitialCondition();
  restart();

  rules = new boolean[10];
  for( int i = 0; i < rules.length; i++ )
  {
    rules[i] = false;//(randy.nextBoolean() & true);
  }
  printRule();
}

void draw()
{
  if ( frameCount % millisBeforeEachNewLayer == 0 && (!pause) )
  {
    computeNextLayer();
  }
  drawCells();
}

public void keyPressed()
{
  if ( key == 'q' )
  {
    incrementRule();
    restart();
  }
  if ( key == 'a' )
  {
    decrementRule();
    restart();
  }
  if( key == 'r' )
  {
    randomizeInitialCondition();
    restart();
  }
  if( key == 'g' )
  {
    restart();
  }
  if( key == 'p' )
  {
    pause = !pause;
  }
  if( key == 'b' )
  {
    blankInitialConditions();
    restart();
  }
  if( key == 'o' )
  {
    oneInMiddleInitialConditions();
    restart();
  }
  if( key == ' ' )
  {
    computeNextLayer();
  }
  if( key == 'z' )
  {
    randomizeRule();
    restart();
  }
}

public void randomizeRule()
{
  for( int i = 0; i < rules.length; i++ )
  {
    rules[i] = (randy.nextBoolean() & true);
  }
  printRule();
}

public void oneInMiddleInitialConditions()
{
  int halfWidth = horizontalDivisions / 2;
  int halfHeight = verticalDivisions / 2;
  blankInitialConditions();
  initialCondition[halfHeight][halfWidth] = true;
}

public void blankInitialConditions()
{
  for( int i = 0; i < initialCondition.length; i++ )
  {
    for( int j = 0; j < initialCondition[0].length; j++ )
    {
      initialCondition[i][j] = false;
    }
  }
}

void copyCellStates( boolean[][] source, boolean[][] destination )
{
  for( int i = 0; i < source.length; i++ )
  {
    for( int j = 0; j < source[0].length; j++ )
    {
      destination[i][j] = source[i][j] & true;
    }
  }
}

void incrementRule()
{
  int position = 0;
  while( true )
  {
    if( rules[position] == false )
    {
      rules[position] = true;
      position--;
      if( position < 0 )
      {
        break;
      }
      for( ; position >= 0; position-- )
      {
        rules[position] = false;
      }
      break;
    }
    else
    {
      position++;
      if( position >= rules.length )
      {
        break;
      }
    }
  }
  printRule();
}

void decrementRule()
{
  int position = 0;
  while( true )
  {
    if( rules[position] == true )
    {
      rules[position] = false;
      position--;
      if( position < 0 )
      {
        break;
      }
      for( ; position >= 0; position-- )
      {
        rules[position] = true;
      }
      break;
    }
    else
    {
      position++;
      if( position >= rules.length )
      {
        break;
      }
    }
  }
  printRule();
}

void drawCells()
{
  int shade = 128;
  for ( int i = 0; i < verticalDivisions; i++ )
  {
    for( int j = 0; j < horizontalDivisions; j++ )
    {
      if( cells[i][j] == true )
      {
        shade = 0;
      }
      else
      {
        shade = 255;
      }
    float x = horizontalDivisionWidth * (float)j;
    float y = verticalDivisionHeight * (float)i;

    drawOneCell( shade, x, y );
    }
  }
}

public void drawOneCell( int shade, float x, float y )
{
  //  set up rect draw specs
  fill( shade );  
  noStroke();
  //stroke( shade );
  pushMatrix();
  translate( x, y );
  rect( 0, 0, horizontalDivisionWidth, verticalDivisionHeight );
  //point( 0, 0 );
  popMatrix();
}

void computeNextLayer()
{
  for ( int i = 0; i < verticalDivisions; i++ )
  {
    int lowerPosition = i + 1;
    int upperPosition = i - 1;
    boolean inUpperBounds = false;
    boolean inLowerBounds = false;
    if( upperPosition > -1 )
    {
      inUpperBounds = true;
    }
    if( lowerPosition < verticalDivisions )
    {
      inLowerBounds = true;
    }
    
    for( int j = 0; j < horizontalDivisions; j++ )
    {
      int leftPosition = j - 1;
      int rightPosition = j + 1;
      
      boolean inLeftBounds = false;
      boolean inRightBounds = false;
      if( leftPosition > -1 )
      {
        inLeftBounds = true;
      }
      if( rightPosition < horizontalDivisions )
      {
        inRightBounds = true;
      }
      
      int state = 0;
      
      //  1, 2, 3
      if( inUpperBounds )
      {
        //  1
        if( inRightBounds )
        {
          //  add for 1
          if( cells[upperPosition][rightPosition] == true )
          {
            state += 1;
          }
        }
        //  2
        //  add for 2
        if( cells[upperPosition][j] == true )
        {
          state += 1;
        }
        //  3
        if( inLeftBounds )
        {
          //  add for 3
          if( cells[upperPosition][leftPosition] == true )
          {
            state += 1;
          }
        }
      }
      
      //  4, 5, 6
      //  4
      if( inRightBounds )
      {
        //  add for 4
        if( cells[i][rightPosition] == true )
        {
          state += 1;
        }
      }
      //  5
      //  add for 5
      if( cells[i][j] == true )
      {
        state += 1;
      }
      //  6
      if( inLeftBounds )
      {
        //  add for 6
        if( cells[i][leftPosition] == true )
        {
          state += 1;
        }
      }
      
      //  7, 8, 9
      if( inLowerBounds )
      {
        //  7
        if( inRightBounds )
        {
          //  add for 7
          if( cells[lowerPosition][rightPosition] == true )
          {
            state += 1;
          }
          
        }
        //  8
        //  add for 8
        if( cells[lowerPosition][j] == true )
        {
          state += 1;
        }
        //  9
        if( inLeftBounds )
        {
          //  add for 9
          if( cells[lowerPosition][leftPosition] == true )
          {
            state += 1;
          }
        }
      }
      newCells[i][j] = (rules[state] & true);
    }
  }
  cells = newCells;
}

public void restart()
{
  copyCellStates( initialCondition, cells );
}

public void randomizeInitialCondition()
{
  //  initialize the cellLayer with one 1 in the middle
  for ( int i = 0; i < initialCondition.length; i++ )
  {
    for( int j = 0; j < initialCondition[0].length; j++ )
    {
      initialCondition[i][j] = randy.nextBoolean();
    }
  }
}

void printRule()
{
  //println( "Rule: " + rule );
  for( int i = 0; i < rules.length; i++ )
  {
    print( i + ":" + rules[i] + "; ");
  }
  println();
}
