function joinCheck() {
	// проверяем, заполнено ли поле reader
	if (document.bookinsert.reader.value.trim().length === 0) {
		alert("Please enter your name.");
		document.bookinsert.reader.focus();
		return false;
	}

	if (document.bookinsert.title.value.trim().length == 0) {
		alert("Please enter the title of the book.");
		document.bookinsert.title.focus();
		return false;
	}
	success();
	return true;
}

function success() {
	alert("Book registration has been completed.")
}

function search() {
	window.location = "ouput_list.php";
}

function modify() {
	alert("Book information has been modified.")
}

