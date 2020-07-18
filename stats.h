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
 * @brief <This file is a header file which includes function declarations>
 *
 * <Analytics of Array>
 *
 * @author <Harshitha Panduranga>
 * @date <July 16 2020>
 *
 */
#ifndef __STATS_H__
#define __STATS_H__


/*
 * @brief A function that prints the statistics of an array including minimum, maximum, mean, and  median.
 * @param The array dataset
 * @param The size of the array
 * @return NULL
 */
    void print_statistics(unsigned char array[], unsigned int size);
 
 /**
 * @brief Given an array of data and a length, prints the array to the screen
 * @param The array dataset
 * @param The size of the array
 * @return NULL
 */
	void print_array(unsigned char array[], unsigned int size);
	
 /**
 * @brief Given an array of data and a length, returns the median value
 * @param The array dataset
 * @param The size of the array
 * @return median value of the array
 */
    int find_median(unsigned char array[], unsigned int size);
    
 /**
 * @brief Given an array of data and a length, returns the mean
 * @param The array dataset
 * @param The size of the array
 * @return median of the array
 */
 	int find_mean(unsigned char array[], unsigned int size);
 
 /**
 * @brief Given an array of data and a length, returns the maximum
 * @param The array dataset
 * @param The size of the array
 * @return maximum alue of the array
 */
 
 	int find_maximum(unsigned char array[], unsigned int size);
 
 /**
 * @brief Given an array of data and a length, returns the minimum
 * @param The array dataset
 * @param The size of the array
 * @return minimum alue of the array
 */

   int find_minimum(unsigned char array[], unsigned int size);
	
/**
 * @brief 	Given an array of data and a length, sorts the array from largest to smallest. 
 * (The zeroth Element should be the largest value, and the last element (n-1) should be the smallest value. )
 * @param The array dataset
 * @param The size of the array
 * @return NULL
 */	
	void sort_array(unsigned char array[], unsigned int size);
	
#endif /* __STATS_H__ */
