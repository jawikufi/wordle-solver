#!/usr/bin/env bash

PATH_SRC=~/Downloads/wordle-solver
function _guess {
	name=guess

	clear
	echo " ****************************************************************"
	echo "               			WORDLE SOLVER                          "
	echo " ****************************************************************"

	# 1. length
	read -p " Length (2-46): [5] " length
	length=${length:-5}
	if [[ $length == "" ]]
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
	read -p " Exclude: " exclude
	if [[ $exclude != "" ]]
	then
		grep -v "[$exclude]" $PATH_SRC/word > $PATH_SRC/word2
		cp $PATH_SRC/word2 $PATH_SRC/word
	fi

	# 3. include
	read -p " Include Pattern (e.g. .oun.): " include
	if [[ $include != "" ]]
	then
		grep "$include" $PATH_SRC/word > $PATH_SRC/word2
		cp $PATH_SRC/word2 $PATH_SRC/word
	fi

	cat $PATH_SRC/word
}

_guess