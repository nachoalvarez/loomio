window.Application ||= {}

$ ->
  Application.hideAllErrorMessages()
  initializeDatepicker()
  initializeHelpNotices()
  collapseHomepageAccordian()

$ ->
  $(".dismiss-help-notice").click (event)->
    $.post($(this).attr("href"))
    $('.help-notice').modal('hide')
    event.preventDefault()
    event.stopPropagation()

$ -> # check if discussion with motions list is empty
  if $("body.groups.show").length > 0 ||  $("body.dashboard.show").length > 0
    if $("#discussions-with-motions").children().html() != ""
      $(".discussion-with-motion-divider").removeClass('hidden')

$ -> # Confirm dialog box for class ".confirm-dialog"
  $("body").on("click", ".confirm-dialog", (event)->
    this_link = $(event.currentTarget)
    titleText = this_link.data("title")
    bodyText = this_link.data("body")
    methodText = this_link.data("method-type")
    if methodText == 'delete'
      buttonType = 'btn-danger'
    else
      buttonType = 'btn-info'
    confirmPath = this_link.data("confirm-path")
    csrf = $('meta[name=csrf-token]').attr("content")
    $('body').append("<div class='modal' id='confirm-dialog-modal'><div class='modal-header'>
      <a data-dismiss='modal' class='close'>×</a><h3>Confirm action</h3></div>
      <form action=#{confirmPath} method='post'>
      <div style='margin:0;padding:0;display:inline'><input name='utf8' type='hidden' value='✓'>
      <input name='_method' type='hidden' value='#{methodText}'>
      <input name='authenticity_token' type='hidden' value=#{csrf}></div>
      <div class='modal-body center'> #{bodyText}</div><div class='modal-footer'>&nbsp;
      <input class= 'btn #{buttonType}', name='commit' type='submit' value='#{titleText}' id='confirm-action'
             data-disable-with='#{titleText}'>
      <a data-dismiss='modal' class='btn'>Cancel</a></div></div></form>"
    )
    $('#confirm-dialog-modal').modal('show')
    $('#confirm-dialog-modal').on('hidden', ->
      $(this).remove()
    event.preventDefault()
    )
  )

### FUNCTIONS ###

collapseHomepageAccordian = () ->
  $(".collapse").collapse()

initializeHelpNotices= () ->
  $(".help-notice").modal(
    backdrop = true
  )

initializeDatepicker = () ->
  $('input.datepicker').datepicker({ dateFormat: 'dd-mm-yy', minDate: - 0})

Application.convertUtcToRelativeTime = ->
  if $(".utc-time").length > 0
    today = new Date()
    month = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun",
               "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ]
    date_offset = new Date()
    offset = date_offset.getTimezoneOffset()/-60
    $(".utc-time").each((index, element)->
      date = $(element).html()
      localDate = Application.timestampToDateObject(date)
      hours = localDate.getHours()
      mins = localDate.getMinutes()
      mins = "0#{mins}" if mins.toString().length == 1
      localDay = new Date(localDate.getFullYear(), localDate.getMonth(), localDate.getDate())
      todayDay = new Date(today.getFullYear(), today.getMonth(), today.getDate())
      if localDay.getTime() == todayDay.getTime()
        if hours < 12
          hours = 12 if hours == 0
          date_string = "#{hours}:#{mins} AM"
        else
          hours = 24 if hours == 12
          date_string = "#{hours-12}:#{mins} PM"
      else
        date_string = "#{localDate.getDate()} #{month[localDate.getMonth()]}"
      $(element).html(String(date_string))
      $(element).removeClass('utc-time')
      $(element).addClass('relative-time')
    )

Application.timestampToDateObject = (timestamp)->
  date = new Date()
  offset = date.getTimezoneOffset()/-60
  date.setYear(timestamp.substring(0,4))
  date.setMonth((parseInt(timestamp.substring(5,7), 10) - 1).toString(), timestamp.substring(8,10))
  date.setHours((parseInt(timestamp.substring(11,13), 10) + offset).toString())
  date.setMinutes(timestamp.substring(14,16))
  return date

Application.getNextURL = (button_url) ->
  current = document.URL
  newURL = current
  lastBackslash = current.lastIndexOf("/")
  #checks if main url has backslash in the way
  if lastBackslash == current.length-1
    current = current.substr(0, lastBackslash)
  #if current is already on a page number remove current page number
  if current.lastIndexOf("?") > -1
    newURL = current.split("?")[0]
  if button_url.lastIndexOf("?") > -1
    page_number = button_url.split("?")
    newURL = newURL + "?" + page_number[1]
  newURL

Application.getPageParam = () ->
  url = $(location).attr("href")
  if url.lastIndexOf("?") > -1
    page = "?" + url.split("?")[1]
    page
  else
    ""

# Placeholder shim
$.placeholder.shim();

# throws a warning if you try to navigate away from a page with unsaved form changes
# todo: translate the warning message
$ ->
  $('.js-warn-before-navigating-away').safetynet()
