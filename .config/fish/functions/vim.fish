function vim --argument file
	if test -z "$file"
		if type -q nvim
			command nvim
		else if type -q vim
			command vim
		else
			command nano
		end
		return 0
	end
	set -f pwd "$PWD"
	if test -n (path extension "$file")
		set -f folder (dirname "$file")
	else
		set -f folder "$file"
		set -f file "."
	end
	if test ! -d "$folder"
		mkdir -p "$folder"
	end
	cd "$folder"
	set -f empty . ..
	if type -q nvim
		command nvim -- "$file"
	else if type -q vim
		command vim -- "$file"
	else
		command nano -- "$file"
	end
	cd "$pwd"
	while is_empty_dir "$folder"; and test ! "$folder" = "."
		rm -rf "$folder"
		set -f folder (dirname "$folder")
	end
end
