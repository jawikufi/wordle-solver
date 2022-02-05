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

	echo " 1 Length"
	echo " 2 Exclude (Grey)"
	echo " 3 Exclude Pattern (Grey / Yellow)"
	echo " 4 Include (Yellow)"
	echo " 5 Include Pattern (Green)"
	echo " "	
	read -rp " [$name] Please select an option: " inputMenu

	case $inputMenu in 
		0|00)
			clear
			exit
		;;

		1)
			# length
			read -p " [Length] 2-46 : [5] " length
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
			sort -R $PATH_SRC/word | head -n20
			echo ""
			< $PATH_SRC/word wc -w
			echo ""

			_menu
		;;

		2)
			# exclude
			read -p " [Exclude] e.g. roe : " exclude
			if [[ $exclude != "" ]]
			then
				grep -v "[$exclude]" $PATH_SRC/word > $PATH_SRC/word2
				cp $PATH_SRC/word2 $PATH_SRC/word
			fi

			echo ""
			sort -R $PATH_SRC/word | head -n20
			echo ""
			< $PATH_SRC/word wc -w
			echo ""

			_menu
		;;

		3)
			# exclude pattern
			l=0
			read -p " [Exclude Pattern] e.g. ....s : " exclude_pattern
			if [[ $exclude_pattern != "" ]]
			then
				for (( i = 0; i < ${#exclude_pattern}; i++ ))
				do
					j="${exclude_pattern:$i:1}"
					dot='....'

					if [[ $i == 0 ]]
					then
						result="$j...."							

					else 
						result=`echo "$dot" | sed "s/./&$j/$i"`
					fi

					if [[ $result != "....." ]]
					then
						grep -v "$result" $PATH_SRC/word > $PATH_SRC/word2
						cp $PATH_SRC/word2 $PATH_SRC/word
					fi
				done
			fi

			echo ""
			sort -R $PATH_SRC/word | head -n20
			echo ""
			< $PATH_SRC/word wc -w
			echo ""

			_menu
		;;

		4)
			# include
			read -p " [Include] e.g. sta : " include
			if [[ $include != "" ]]
			then
				for (( i = 0; i < ${#include}; i++ ))
				do
					grep "${include:$i:1}" $PATH_SRC/word > $PATH_SRC/word2
					cp $PATH_SRC/word2 $PATH_SRC/word
				done
			fi

			echo ""
			sort -R $PATH_SRC/word | head -n20
			echo ""
			< $PATH_SRC/word wc -w
			echo ""

			_menu
		;;

		5)
			# include pattern
			read -p " [Include Pattern] e.g. sta.. : " include_pattern
			if [[ $include_pattern != "" ]]
			then
				grep "$include_pattern" $PATH_SRC/word > $PATH_SRC/word2
				cp $PATH_SRC/word2 $PATH_SRC/word
			fi

			echo ""
			sort -R $PATH_SRC/word | head -n20
			echo ""
			< $PATH_SRC/word wc -w
			echo ""

			_menu
		;;

		*) 
		_menu
		;;
	
	esac
}

clear
_menu