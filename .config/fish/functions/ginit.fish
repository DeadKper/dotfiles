function ginit --argument-names commit_message
	if test -z "$commit_message"
		set commit_message "init"
	end

	git init && git branch -m main && git add -A && git commit -m "$commit_message"
end
