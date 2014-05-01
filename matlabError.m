function scrap()
	try
		runError(2);
	catch err
		err = addCause(err, MException('Scrap:ScrapError', 'This is a test error'));
		throw(err);
		fprintf('Error happened');
	end
end



function out = runError(integ)
	array = [];
	out = array(integ);
end