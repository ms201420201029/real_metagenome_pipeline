(function ($) {

	//jQuery for page scrolling feature - requires jQuery Easing plugin
	$(function() {
		$('.navbar-nav li a').bind('click', function(event) {
			var $anchor = $(this);
			$('html, body').stop().animate({
				scrollTop: $($anchor.attr('href')).offset().top
			}, 1500, 'easeInOutExpo');
			event.preventDefault();
		});
		$('.page-scroll a').bind('click', function(event) {
			var $anchor = $(this);
			$('html, body').stop().animate({
				scrollTop: $($anchor.attr('href')).offset().top
			}, 1500, 'easeInOutExpo');
			event.preventDefault();
		});
	});

})(jQuery);


$(function(){
  // 循环轮播到上一个项目
  $(".prev-slide").click(function(){
	 $("#myCarousel").carousel('prev');
  });
  // 循环轮播到下一个项目
  $(".next-slide").click(function(){
	 $("#myCarousel").carousel('next');
  });
  // 循环轮播到某个特定的帧 
  $("#slide-1-0").click(function(){
	 $("#myCarousel1").carousel(0);
  });
  $("#slide-1-1").click(function(){
	 $("#myCarousel1").carousel(1);
  });
  $("#slide-1-2").click(function(){
	 $("#myCarousel1").carousel(2);
  });
  $("#slide-1-3").click(function(){
	 $("#myCarousel1").carousel(3);
  });
  $("#slide-1-4").click(function(){
	 $("#myCarousel1").carousel(4);
  });

  $("#slide-2-0").click(function(){
	 $("#myCarousel2").carousel(0);
  });
  $("#slide-2-1").click(function(){
	 $("#myCarousel2").carousel(1);
  });
  $("#slide-2-2").click(function(){
	 $("#myCarousel2").carousel(2);
  });
  $("#slide-2-3").click(function(){
	 $("#myCarousel2").carousel(3);
  });
  $("#slide-2-4").click(function(){
	 $("#myCarousel2").carousel(4);
  });

  $("#slide-3-0").click(function(){
	 $("#myCarousel3").carousel(0);
  });
  $("#slide-3-1").click(function(){
	 $("#myCarousel3").carousel(1);
  });
  $("#slide-3-2").click(function(){
	 $("#myCarousel3").carousel(2);
  });
  $("#slide-3-3").click(function(){
	 $("#myCarousel3").carousel(3);
  });
  $("#slide-3-4").click(function(){
	 $("#myCarousel3").carousel(4);
  });
  $("#slide-3-5").click(function(){
	 $("#myCarousel3").carousel(5);
  });

  $("#slide-4-0").click(function(){
	 $("#myCarousel4").carousel(0);
  });
  $("#slide-4-1").click(function(){
	 $("#myCarousel4").carousel(1);
  });
  $("#slide-4-2").click(function(){
	 $("#myCarousel4").carousel(2);
  });
  $("#slide-4-3").click(function(){
	 $("#myCarousel4").carousel(3);
  });
  $("#slide-4-4").click(function(){
	 $("#myCarousel4").carousel(4);
  });
  $("#slide-4-5").click(function(){
	 $("#myCarousel4").carousel(5);
  });
   
  $("#slide-5-0").click(function(){
	 $("#myCarousel5").carousel(0);
  });
  $("#slide-5-1").click(function(){
	 $("#myCarousel5").carousel(1);
  });
  $("#slide-5-2").click(function(){
	 $("#myCarousel5").carousel(2);
  });
  $("#slide-6-0").click(function(){
	 $("#myCarousel6").carousel(0);
  });
  $("#slide-6-1").click(function(){
	 $("#myCarousel6").carousel(1);
  });
  $("#slide-6-2").click(function(){
	 $("#myCarousel6").carousel(2);
  });
  $("#slide-7-0").click(function(){
	 $("#myCarousel7").carousel(0);
  });
  $("#slide-7-1").click(function(){
	 $("#myCarousel7").carousel(1);
  });
  $("#slide-7-2").click(function(){
	 $("#myCarousel7").carousel(2);
  });

});

