/******************************************************************************
 * Copyright (C) 2017 by Alex Fosdick - University of Colorado
 *
 * Redistribution, modification or use of this software in source or binary
 * forms is permitted as long as the files maintain this copyright. Users are 
 * permitted to modify this and use it to learn about the field of embedded
 * software. Alex Fosdick and the University of Colorado are not liable for any
 * misuse of this material. 
 *
 *****************************************************************************/
/**
 * @file <stats.h> 
 * @brief <This file is a C source file which includes function definitions and implementation>
 *
 * <Analytics of Array dataset>
 *
 * @author <Harshitha Panduranga>
 * @date <July 16 2020>
 *
 */



#include <stdio.h>
#include "stats.h"
#define SIZE (40)

/* Size of the Data Set */


void main() {
  
  unsigned char test[SIZE] = { 34, 201, 190, 154,   8, 194,   2,   6,
                              114, 88,   45,  76, 123,  87,  25,  23,
                              200, 122, 150, 90,   92,  87, 177, 244,
                              201,   6,  12,  60,   8,   2,   5,  67,
                                7,  87, 250, 230,  99,   3, 100,  90};

  /* Other Variable Declarations Go Here */
  
  /* Statistics and Printing Functions Go Here */
  
  print_statistics(test,SIZE);

}

/* Add other Implementation File Code Here */


	print_statistics(unsigned char test[], unsigned int n){
		
	printf("The array dataset:\n");
	print_array(test, SIZE);
	
	printf("The array statistics are as follows:\n\n");
	
	printf("Sorted array:\n");
	sort_array(test, SIZE);
	print_array(test, SIZE);
	
	printf("Median of the array is: %d\n", find_median(test, SIZE));
	printf("Mean of the array is: %d\n", find_mean(test, SIZE));
	printf("Maximum value of the array is: %d\n", find_maximum(test, SIZE));
	printf("Minimum value of the array is: %d\n", find_minimum(test, SIZE));
		
	return;			
	}

	print_array(unsigned char test[], unsigned int n){
		int i;                               
		for(i=0;i<SIZE;i++){
					if(i%8 == 0)
					printf("\n");
						printf("%d, ",test[i]);
		} 
		printf("\n\n");
	}
	
	void swap(unsigned char *xp, unsigned char *yp) { 
	
        unsigned char temp = *xp; 
        *xp = *yp; 
        *yp = temp; 
   }
   
	sort_array(unsigned char test[], unsigned int n) { 
	
        int i, j; 
        for (i = 0; i < SIZE-1; i++)  {    
        for (j = 0; j < SIZE-i-1; j++){
       	if (test[j] > test[j+1]) 
              swap(&test[j], &test[j+1]);               
           }  
       }  
	}


	find_median(unsigned char test[], unsigned int n){
		
		int median = 0;
		int i=0;
		i = SIZE/2;
		median = test[i];
		return(median);	
	}


	find_mean(unsigned char test[], unsigned int n){
		
		int i;
		int sum = 0;
		for(i=0;i<SIZE;i++)
		sum = sum+test[i];
		return(sum/SIZE);
   }

	find_maximum(unsigned char test[], unsigned int n){
		
		return(test[SIZE-1]);	
	}  
	
	find_minimum(unsigned char test[], unsigned int n){
		
		return(test[0]);
	}

