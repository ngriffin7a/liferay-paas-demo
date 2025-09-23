console.group('Accordion Container');
console.log('fragmentElement', fragmentElement);
console.log('configuration', configuration);
console.groupEnd();
 $('.panel-collapse').on('show.bs.collapse', function () {
    $(this).siblings('.panel-heading').addClass('active');
  });

  $('.panel-collapse').on('hide.bs.collapse', function () {
    $(this).siblings('.panel-heading').removeClass('active');
  });