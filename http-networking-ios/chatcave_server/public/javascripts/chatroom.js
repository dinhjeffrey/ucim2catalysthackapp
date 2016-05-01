var lastMessageID = null;

var pollForMessages = function() {
  $.ajax(document.URL + '/messages?since=' + lastMessageID, {
    method: 'GET',
    accepts: { json: 'application/json' },
    dataType: 'json',
    error: function(xhr, status, error) {
      console.error("Unable to fetch new messages: " + error);
    },
    success: function(data, status, xhr) {
      var messages = data || [];

      data.forEach(function(message) {
        appendMessage(message);
      });

      if (data.length > 0) {
        lastMessageID = data[data.length - 1].id;
      };
    }
  })

  setTimeout(pollForMessages, 1000);
};

var appendMessage = function(message) {
  var li = $('<li></li>');
  var time = new Date(message.timestamp).toTimeString();
  var timestamp = $('<span class="timestamp"></span>').append(time + ' ');
  var author = $('<span class="author"></span>').append(message.author + ' ');
  if (message.type === 'chat') {
    li.append(timestamp).append(author).append(message.text);
  }
  else if (message.type === 'join') {
    var status = $('<span class="status"></span>').append("has joined the chat");
    li.append(timestamp).append(author).append(status);
  }
  else if (message.type === 'leave') {
    var status = $('<span class="status"></span>').append("has left the chat");
    li.append(timestamp).append(author).append(status);
  }

  $('#messages').append(li);
};

$(function() {
  // Setup JS-handler for AJAX form
  $('#new_message').submit(function(e) {
    e.preventDefault();

    var messageText = $('#new_message #text').val();
    if (messageText !== null && messageText.length > 0) {
      var action = $('#new_message').attr('action');
      $.ajax(action, {
        method: 'POST',
        accepts: { json: 'application/json' },
        dataType: 'json',
        data: $('#new_message').serialize(),
        error: function(xhr, status, error) {
          alert("Failed to post message: " + error);
        },
        success: function(message, status, xhr) {
          $('#new_message #text').val('');
          appendMessage(message);
          lastMessageID = message.id;
        }
      });
    }
  });

  // Figure out most recent message id
  lastMessageID = $('#messages li').last().attr('message_id');

  // Setup AJAX polling, if we're in the room
  if ($('#messages').length > 0) {
    setTimeout(pollForMessages, 2000);
  }
});