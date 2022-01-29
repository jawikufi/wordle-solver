#!/usr/bin/env bash

PATH_SRC=~/Downloads/wordle-solver
function _guess {
	clear
	echo " ****************************************************************"
	echo "               		   WORDLE SOLVER                           "
	echo " ****************************************************************"

	# 1. length
	read -p " [1 of 4] Length (2-46): [5] " length
	length=${length:-5}

	if [[ -n ${length//[0-9]/} ]]
	then
		exit
	fi

	if (( length < 2 || length > 46 ))
	then
		exit
	fi
	
	str='[a-z]'
	for (( i = 1; i <= $length; i++ )) 
	do
		pattern="${pattern}${str}"
	done

	touch $PATH_SRC/word
	touch $PATH_SRC/word2
	grep "^$pattern$" $PATH_SRC/words > $PATH_SRC/word
	
	# 2. exclude
	read -p " [2 of 4] Exclude: " exclude
	if [[ $exclude != "" ]]
	then
		grep -v "[$exclude]" $PATH_SRC/word > $PATH_SRC/word2
		cp $PATH_SRC/word2 $PATH_SRC/word
	fi

	# 3. contains
	read -p " [3 of 4] Include: " include
	if [[ $include != "" ]]
	then
		for (( i = 0; i < ${#include}; i++ ))
		do
			grep "${include:$i:1}" $PATH_SRC/word > $PATH_SRC/word2
			cp $PATH_SRC/word2 $PATH_SRC/word
		done
	fi

	# 4. include
	read -p " [4 of 4] Include Pattern (e.g. .oun.): " pattern2
	if [[ $pattern2 != "" ]]
	then
		grep "$pattern2" $PATH_SRC/word > $PATH_SRC/word2
		cp $PATH_SRC/word2 $PATH_SRC/word
	fi

	echo ""
	sort -R $PATH_SRC/word | head -n5
	echo ""
}

_guess