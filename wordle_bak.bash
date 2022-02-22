#!/usr/bin/env bash

PATH_SRC=~/Downloads/wordle-solver
# DICTIONARY=words
DICTIONARY=words_scrabble

function _result {
	echo ""
	sort -R $PATH_SRC/word | head -n20
	echo ""
	< $PATH_SRC/word wc -w
	echo ""
}

function _menu {
	name=menu

	echo " ****************************************************************"
	echo "               		   WORDLE SOLVER                           "
	echo " ****************************************************************"

	echo " 0 Exit "
	echo " "		

	if [[ -z "$length" ]]
	then
	    length=5
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

	if [[ -z "$result" ]]
	then
	    result=
	fi

	echo " 1 Length [$length] "
	echo " 2 Result (0 Grey / 1 Yellow / 2 Green) [$result] "
	# echo " 3 Exclude (Grey) [$exclude] "
	# echo " 4 Exclude Pattern (Yellow) [$exclude_pattern] "
	# echo " 5 Include (Yellow) [$include] "
	# echo " 6 Include Pattern (Green) [$include_pattern] "
	echo " "	
	read -rp " [$name] Please select an option: " inputMenu

	case $inputMenu in 
		0|00)
			# exit
			length=5
			
			pattern=''
			str='[a-z]'
			for (( i = 1; i <= $length; i++ )) 
			do
				pattern="${pattern}${str}"
			done

			touch $PATH_SRC/word
			touch $PATH_SRC/word2
			grep "^$pattern$" $PATH_SRC/$DICTIONARY > $PATH_SRC/word

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

			_result
			_menu
		;;

		2)
			# result
			read -p " [Input] e.g. lieus : " answer
			read -p " [Color] e.g. 01000 : " answer2

			if [[ $answer != "" && $answer2 != "" ]]
			then
				if [[ -z "$result" ]]
				then
				    result="$answer $answer2"

				else 
					result="$result $answer $answer2"
				fi

				answerIncludePattern=
				for (( i = 0; i < ${#answer}; i++ ))
				do
					j="${answer:$i:1}"
					k="${answer2:$i:1}"

					if [[ $k == 0 ]]
					then
						# grey
						# 2. Exclude
						if [[ -z "$exclude" ]]
						then
						    exclude="$j"

						else 
							exclude="$exclude$j"
						fi

						grep -v "[$j]" $PATH_SRC/word > $PATH_SRC/word2
						cp $PATH_SRC/word2 $PATH_SRC/word

						answerIncludePattern="$answerIncludePattern."

					elif [[ $k == 1 ]]
					then
						# yellow
						# 4. Include
						if [[ -z "$include" ]]
						then
						    include="$j"

						else 
							include="$include$j"
						fi

						grep "$j" $PATH_SRC/word > $PATH_SRC/word2
						cp $PATH_SRC/word2 $PATH_SRC/word

						answerIncludePattern="$answerIncludePattern."

						# 3. Exclude Pattern
						dot='....'

						if [[ $i == 0 ]]
						then
							answer_exclude_pattern="$j...."							

						else 
							answer_exclude_pattern=`echo "$dot" | sed "s/./&$j/$i"`
						fi

						if [[ $answer_exclude_pattern != "....." ]]
						then
							grep -v "$answer_exclude_pattern" $PATH_SRC/word > $PATH_SRC/word2
							cp $PATH_SRC/word2 $PATH_SRC/word

							if [[ -z "$exclude_pattern" ]]
							then
							    exclude_pattern="$answer_exclude_pattern"

							else 
								exclude_pattern="$exclude_pattern $answer_exclude_pattern"
							fi
						fi


					elif [[ $k == 2 ]]
					then
						# green
						echo ""
						answerIncludePattern="$answerIncludePattern$j"
					fi

					# result="$result $j$k"
				done

				# 5. Include Pattern
				if [[ -z "$include_pattern" && $answerIncludePattern != "....." ]]
				then
				    include_pattern="$answerIncludePattern"

				elif [[ $answerIncludePattern != "....." ]]
				then
					include_pattern="$include_pattern $answerIncludePattern"
				fi

				if [[ $answerIncludePattern != "....." ]]
				then
					grep "$answerIncludePattern" $PATH_SRC/word > $PATH_SRC/word2
					cp $PATH_SRC/word2 $PATH_SRC/word
				fi
			fi

			_result
			_menu
		;;

		3)
			# exclude
			read -p " [Exclude] e.g. roe : " answer
			if [[ $answer != "" ]]
			then
				if [[ -z "$exclude" ]]
				then
				    exclude="$answer"

				else 
					exclude="$exclude$answer"
				fi

				grep -v "[$exclude]" $PATH_SRC/word > $PATH_SRC/word2
				cp $PATH_SRC/word2 $PATH_SRC/word
			fi

			_result
			_menu
		;;

		4)
			# exclude pattern
			l=0
			read -p " [Exclude Pattern] e.g. ....s : " answer
			if [[ $answer != "" ]]
			then
				if [[ -z "$exclude_pattern" ]]
				then
				    exclude_pattern="$answer"

				else 
					exclude_pattern="$exclude_pattern $answer"
				fi

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

			_result
			_menu
		;;

		5)
			# include
			read -p " [Include] e.g. roe : " answer
			if [[ $answer != "" ]]
			then
				if [[ -z "$include" ]]
				then
				    include="$answer"

				else 
					include="$include$answer"
				fi

				for (( i = 0; i < ${#include}; i++ ))
				do
					grep "${include:$i:1}" $PATH_SRC/word > $PATH_SRC/word2
					cp $PATH_SRC/word2 $PATH_SRC/word
				done
			fi

			_result
			_menu
		;;

		6)
			# include pattern
			read -p " [Include Pattern] e.g. sta.. : " answer
			if [[ $answer != "" ]]
			then
				if [[ -z "$include_pattern" ]]
				then
				    include_pattern="$answer"

				else 
					include_pattern="$include_pattern $answer"
				fi

				grep "$answer" $PATH_SRC/word > $PATH_SRC/word2
				cp $PATH_SRC/word2 $PATH_SRC/word
			fi

			_result
			_menu
		;;

		*) 
		_result
		_menu
		;;
	
	esac
}

clear
_menu