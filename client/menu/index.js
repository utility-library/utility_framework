var _gdata = undefined;
var importing = false;

function ChangeValue(first, index, value) {
    if ((_gdata[index].count + value) >= _gdata[index].min && (_gdata[index].count + value) <= _gdata[index].max) {
        _gdata[index].count = _gdata[index].count + value
    
        $("#slider_count_"+index).html(_gdata[index].count)

        if (!first) {
            var data = JSON.parse($('#'+index).attr('_data'))
            data["count"] = $("#slider_count_"+index).html()
            data = JSON.stringify(data)
    
            //console.log("Posting = "+data)
            $.post('http://utility_framework/slider', data);
        }

    } else {
        $("#slider_count_"+index).addClass("limit")
        $("#slider_count_"+index).on("animationend webkitAnimationEnd oAnimationEnd MSAnimationEnd", function(){
            $(this).removeClass("limit");
       })
    }

    //console.log("Index "+index)
    //console.log("New value "+_gdata[index].count+"\n")
}

window.addEventListener('message', function(event){	
    var data = event.data 

    if (data.clipboard) {
        if (data.text != undefined) {
            const text = document.createElement('textarea');
            text.value = data.text;
            text.setAttribute('readonly', '');

            text.style.opacity = 0.0;
            document.body.appendChild(text);

            text.select();
            document.execCommand('copy');
            
            document.body.removeChild(text);
        }
    } else if (data.dialog) {
        $(".menu").append(`
        <input type="text" value="" placeholder="${data.placeholder}" id="import">
        `);

        var input = document.getElementById('import');
        input.setAttribute('size',input.getAttribute('placeholder').length);

        $("#import").keypress(function( event ) {
            if ( event.which == 13 ) {
                event.preventDefault();
                $.post('http://utility_framework/DialogData', JSON.stringify(
                    {
                        "text":$('#import').val()
                    }
                ));
                $('#import').remove()
            }
        });
    } else {
        if (data.update) {
            //console.log(JSON.stringify(data.content, null, 4))
            _gdata = data.content
            if (data.refresh) {
                $(".menu ul").html("")
                $(".menu_title").html("")
                GenerateMenu(data.content, data.closeLabel, data.title)
            }
        } else {
            if (data.open) {
                //console.log(JSON.stringify(data.content, null, 4))

                _gdata = data.content
                GenerateMenu(data.content, data.closeLabel, data.title)
            } else {
                $('.menu').addClass('slide-out');

                setTimeout(() => {
                    $(".menu").html("<ul></ul>")
                    $(".menu").removeClass('slide-out')
                }, 500);
            }
        }
    }

})

document.onkeyup = function (data) {
	if (data.which == 27) {
		$.post('http://utility_framework/close', '{}');
	}
};

var breakLoop = [];
function GenerateMenu(data, closeLabel, title) {
    console.log(closeLabel, title)
    $(".menu").append("<div class='menu_title'>"+ConvertEmoji(title)+"</div>");

    for (let i = 0; i < data.length; i++) {
        if (data[i].type == "scroll") {
            data[i].label = ConvertEmoji(data[i].label)

            $(".menu ul").append(`
                <li class='menu_option_slider' id='`+i+`'>
                    <div class="slider">
                        <div class="text">`+data[i].label+`</div>
                        <i class='fas fa-arrow-left' id='leftarrow`+i+`' onclick='ChangeValue(false, `+i+`, -1)'></i>
                        
                        <span class='sliderCount' id='slider_count_`+i+`'>
                            `+data[i].count+`
                        </span>

                        <i class='fas fa-arrow-right' id='rightarrow`+i+`' onclick='ChangeValue(false, `+i+`, 1)'></i>
                    </div>
                </li>
            `);

            $('#'+i).attr("_data", JSON.stringify(data[i]));

            // Left arrow holded
                $("#leftarrow"+i)
                .mouseup(function() {
                    breakLoop[i] = true
                })
                .mousedown(function() {
                    breakLoop[i] = false

                    setTimeout(() => {
                        if (!breakLoop[i]) {
                            function Loop() {
                                setTimeout(() => {
                                    if (!breakLoop[i]) {
                                        ChangeValue(false, i, -1)
                                        Loop()
                                    }
                                }, 100);
                            }
                            Loop()
                        }
                    }, 300);
                });

            // Right arrow holded
                $("#rightarrow"+i)
                .mouseup(function() {
                    breakLoop[i] = true
                })
                .mousedown(function() {
                    breakLoop[i] = false

                    setTimeout(() => {
                        if (!breakLoop[i]) {
                            function Loop() {
                                setTimeout(() => {
                                    if (!breakLoop[i]) {
                                        ChangeValue(false, i, 1)
                                        Loop()
                                    }
                                }, 100);
                            }
                            Loop()
                        }
                    }, 300);
                });

            ChangeValue(true, i, 0)
        } else {
            $(".menu ul").append(`
                <li class='menu_option' id='`+i+`'>
                    `+ConvertEmoji(data[i].label)+`
                </li>
            `);

            $('#'+i).attr("_data", JSON.stringify(data[i]));
        }
    }

    $(".menu ul").append("<li class='menu_option' id='close'>"+ConvertEmoji(closeLabel)+"</li>");

    $(".menu_option").click(function(event){
        if (event.target.id == "close") {
            $.post('http://utility_framework/backsubmenu', '{}');
        } else {
            $.post('http://utility_framework/button_selection', $('#'+event.target.id).attr('_data'));
        }
    })
};

function ConvertEmoji(str) {
    var _ = [];
    var __ = [];

    //console.log("Str = "+str)

    for(var i=0; i<str.length;i++) {
        if (str[i] === "<") _.push(i);
    }
    for(var i=0; i<str.length;i++) {
        if (str[i] === ">") __.push(i);
    }

    //console.log(__.length, _.length)
    for(var i=0; i<_.length; i++) {
        for(var i2=0; i2<__.length; i2++) {
            var emojiName = str.substring(_[i2] + 1,__[i2])

            console.log(emojiName.includes("fa-"))
            if (emojiName.includes("fa-")) {
                str = str.replace("<"+emojiName+">", "<i class='fas "+emojiName+"'></i>")
            }
        }  
    }
    return str
}