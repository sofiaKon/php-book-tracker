function joinCheck() {
	// проверяем, заполнено ли поле reader
	if (document.log.reader.value.trim().length === 0) {
		alert("Please enter your name.");
		document.log.reader.focus();
		return false;
	}

	if (document.log.title.value.trim().length == 0) {
		alert("Please enter the title of the book.");
		document.log.title.focus();
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

