  var codeMirrorSettings =  
    {
        lineNumbers: true,
        matchBrackets: true,
        theme: "xq-dark",
        keyMap: "emacs"
    };
  var editors = {};
  function clearEditorState() {
    $('#files-list .file-title.open').removeClass('open');
    $('div.tab:not(.hidden)').addClass('hidden');
  };
  $(document).ready(function(){
    $.get("/ajax/explorer/default.xq",{'directory-start':'/'},
        function(data) {
            $('#explorer-window').html(data.html);
        },
        'json'
    );
  	$('#files-list').on('click','a.file-title',function(){
        clearEditorState();
        $(this).addClass('open');
        $('#'+$(this).data('id')).removeClass('hidden');
    });
  	$('#files-list').on('click','a.file-close',function(){
		var curItem = $(this),
            id = curItem.data('id'),
			tab = $('#'+id);
        if (!tab.hasClass('hidden')) {
			$('.tab:last').removeClass('hidden');
            $('.file-title:last:not(#file-name-template)').addClass('open');
        }
        delete editors[id];
		tab.remove();
		curItem.parent().remove();
    });
  	$('#explorer-window').on('click','a.directory.closed',function(){
        if ($(this).next('ul.directory-listing').length) {
            $(this).next('ul.directory-listing').show();
            $(this).addClass('open').removeClass('closed').next('ul.directory-listing').show();
        } else {
            var dir = $(this);
            $.get("/ajax/explorer/default.xq",{'directory-start':dir.data('directory')},
                function(data) {
                    dir.addClass('open').removeClass('closed').after(data.html);
                },
                'json'
            );
        }
    });
  	$('#explorer-window').on('click','a.directory.open',function(){
        $(this).next('ul.directory-listing').hide();
        $(this).addClass('closed').removeClass('open');
    });
  	$('#explorer-window').on('click','a.file',function(){
        var fileName = $(this).text(),
            fileLocation = $(this).data('file'),
            id = fileLocation.replace(/^[^a-zA-z]+/,'').replace(/[\/\.]/g,'_');
        clearEditorState();
        if ($(id).length) {
            $(id).removeClass('hidden');
            $('.file-title[data-id="' + id + '"]').addClass('open');
        } else {
            $.get("/ajax/actions/open.xq",{'location':fileLocation},
                function(data) {
					var newLI =  $('#file-name-template').clone().removeAttr('id');
					$('#files-list').append(
						newLI.find('a.file-title').data('id',id).text(fileName).addClass('open').end()
							.find('a.file-close').data('id',id).end().css('display','')
					);
                    $('.tab:last').after(
                        $('#file-template').clone()
                            .removeClass('hidden').attr('id',id).css('display','')
                            .find('input[name="location"]').val(fileLocation).end()
                            .find('textarea.editor').data('id',id).val(data.contents).end()
                    );
                    editors[id] = new CodeMirrorUI(
                            $('#'+id).find('textarea.editor')[0],
                            {imagePath: '/static/images/silk',
                            saveCallback: function() {
                                $('#'+id+' textarea.editor').val(editors[id].mirror.getValue());
                                $.post("/ajax/actions/save.xq", $('#'+id+' form.moxide').serialize());
                            },
                            buttons: ['search', 'undo', 'redo','save', 'jump', 'reindentSelection', 'reindent','about']},
                            codeMirrorSettings
                        );
                },
                'json'
            );
        }
    });
  });