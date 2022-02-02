#!/usr/bin/env bash

PATH_SRC=~/Downloads/wordle-solver
DICTIONARY=words_scrabble
function _menu {
	name=menu

	echo " ****************************************************************"
	echo "               		   WORDLE SOLVER                           "
	echo " ****************************************************************"

	echo " 0 Exit "
	echo " "		

	echo " 1 New"
	echo " 2 Exclude"
	echo " 3 Exclude Pattern"
	echo " 4 Include"
	echo " 5 Include Pattern"
	echo " "	
	read -rp " [$name] Please select an option: " inputMenu

	case $inputMenu in 
		0|00)
			clear
			exit
		;;

		1)
			# length
			read -p " [1 of 5] Length (2-46): [5] " length
			length=${length:-5}

			if [[ -n ${length//[0-9]/} ]]
			then
				exit
			fi

			if (( length < 2 || length > 46 ))
			then
				exit
			fi
			
			pattern=''
			str='[a-z]'
			for (( i = 1; i <= $length; i++ )) 
			do
				pattern="${pattern}${str}"
			done

			touch $PATH_SRC/word
			touch $PATH_SRC/word2
			grep "^$pattern$" $PATH_SRC/$DICTIONARY > $PATH_SRC/word

			echo ""
			sort -R $PATH_SRC/word | head -n10
			echo ""

			_menu
		;;

		2)
			# exclude
			read -p " [2 of 5] Exclude: " exclude
			if [[ $exclude != "" ]]
			then
				grep -v "[$exclude]" $PATH_SRC/word > $PATH_SRC/word2
				cp $PATH_SRC/word2 $PATH_SRC/word
			fi

			echo ""
			sort -R $PATH_SRC/word | head -n10
			echo ""

			_menu
		;;

		3)
			# exclude pattern
			read -p " [3 of 5] Exclude Pattern (e.g. .i..s): " exclude_pattern
			if [[ $exclude_pattern != "" ]]
			then
				grep -v "$exclude_pattern" $PATH_SRC/word > $PATH_SRC/word2
				cp $PATH_SRC/word2 $PATH_SRC/word
			fi

			echo ""
			sort -R $PATH_SRC/word | head -n10
			echo ""

			_menu
		;;

		4)
			# include
			read -p " [4 of 5] Include: " include
			if [[ $include != "" ]]
			then
				for (( i = 0; i < ${#include}; i++ ))
				do
					grep "${include:$i:1}" $PATH_SRC/word > $PATH_SRC/word2
					cp $PATH_SRC/word2 $PATH_SRC/word
				done
			fi

			echo ""
			sort -R $PATH_SRC/word | head -n10
			echo ""

			_menu
		;;

		5)
			# include pattern
			read -p " [5 of 5] Include Pattern (e.g. .oun.): " include_pattern
			if [[ $include_pattern != "" ]]
			then
				grep "$include_pattern" $PATH_SRC/word > $PATH_SRC/word2
				cp $PATH_SRC/word2 $PATH_SRC/word
			fi

			echo ""
			sort -R $PATH_SRC/word | head -n10
			echo ""

			_menu
		;;

		*) 
		_menu
		;;
	
	esac
}

_menu