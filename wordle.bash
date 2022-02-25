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
			x=1
			while [ $x -le 6 ]
			do
				read -p " [Input $x] e.g. lieus : " answer
				while [[ "$answer" =~ [^a-zA-Z] || -z "$answer" ]]
				do        
					_result
				   	echo " Input only alphabet characters"     
				   	   
					read -p " [Input $x] e.g. lieus : " answer
				done

				while [[ ${#answer} -gt $length || ${#answer} -lt $length ]]
				do        
					_result
				   	echo " Input only $length length"     
				   	   
					read -p " [Input $x] e.g. lieus : " answer
				done

				read -p " [Color $x] e.g. 01000 : " answer2
				while [[ "$answer2" =~ [^012] || -z "$answer2" ]]
				do        
					_result
				   	echo " Input only number characters 0 to 2"     
				   	   
					read -p " [Color $x] e.g. 01000 : " answer2
				done

				while [[ ${#answer2} -gt $length || ${#answer2} -lt $length ]]
				do        
					_result
				   	echo " Input only $length length"     
				   	   
					read -p " [Color $x] e.g. 01000 : " answer2
				done

				if [[ $answer != "" && $answer2 == "22222" ]]
				then
					echo " You're the man!"
					exit
				fi

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

			  	x=$(( $x + 1 ))
			done

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