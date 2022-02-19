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

	if [[ -z "$length" ]]
	then
	    length=46
	fi

	if [[ -z "$exclude" ]]
	then
	    exclude=
	fi

	if [[ -z "$exclude_pattern" ]]
	then
	    exclude_pattern=
	fi

	if [[ -z "$include" ]]
	then
	    include=
	fi

	if [[ -z "$include_pattern" ]]
	then
	    include_pattern=
	fi

	echo " 1 Length [$length] "
	echo " 2 Exclude (Grey) [$exclude] "
	echo " 3 Exclude Pattern (Grey / Yellow) [$exclude_pattern] "
	echo " 4 Include (Yellow) [$include] "
	echo " 5 Include Pattern (Green) [$include_pattern] "
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
			read -p " [Exclude] e.g. roe : " answer
			if [[ $answer != "" ]]
			then
				exclude="$exclude$answer"
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
			read -p " [Exclude Pattern] e.g. ....s : " answer
			if [[ $answer != "" ]]
			then
				exclude_pattern="$exclude_pattern $answer"

				for (( i = 0; i < ${#answer}; i++ ))
				do
					j="${answer:$i:1}"
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
			read -p " [Include] e.g. roe : " answer
			if [[ $answer != "" ]]
			then
				include="$include$answer"

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
			read -p " [Include Pattern] e.g. sta.. : " answer
			if [[ $answer != "" ]]
			then
				include_pattern="$include_pattern $answer"

				grep "$answer" $PATH_SRC/word > $PATH_SRC/word2
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