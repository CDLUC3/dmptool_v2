/*
  Copyright 2013 The Australian National University
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*******************************************************************************/

/**
 * jQuery plugin for ORCID Widget integration
 * @author Minh Duc Nguyen <minh.nguyen@ands.org.au>
 */
;(function($) {
	
	//settings
    var WIDGET_NAME = "ANDS Orcid service";
    var WIDGET_ID = "_orcid_widget_list";

    //init the orcid_widget()
    $.fn.orcid_widget = function(options, param) {

    	//set params
		param = typeof(param) === 'undefined' ? false : param;

		var defaults = {
		    //location (absolute URL) of the jsonp proxy
		    search_endpoint: 'https://pub.orcid.org/v1.1/search/orcid-bio?q=',
		   	lookup_endpoint: 'https://pub.orcid.org/v1.1/',

		    //auto _lookup once init
		    pre_lookup: false,

		    //Text Settings
		    search: true,
		    pre_open_search: false,
		    tooltip:false,
		    info_box_class:'info-box',
		    search_text: '<i class="icon-search"></i> Search',
		    search_class: 'orcid_search btn btn-default btn-small',
		    lookup: true,
		    lookup_text: 'Look up',
		    lookup_class: 'orcid_lookup btn btn-default btn-small',
		    before_html: '<span class="orcid_before_html">http://orcid.org/</span>',
		    wrap_html: '<div class="orcid_wrapper"></div>',
		    result_success_class: 'orcid_success_div',
		    result_error_class: 'orcid_error_div',
		    search_div_class: 'orcid_search_div',
		    nohits_msg: '<p>No matches found<br/>If you wish to register for an orcid please click <a href="https://orcid.org/register" target="_blank" style="float:none;padding:0px">here</a></p>',
		    query_text: 'Search Query:',
		    search_text_btn: 'Search',
		    close_search_text_btn: '[x]',

		    //custom hooks and handlers
		    lookup_error_handler: false,
		    lookup_success_handler: false,
		    post_lookup_success_handler: false,

		    //auto close the search box once a value is chosen
		    auto_close_search: true

		};
		//bind and merge the defaults with the given options
		var settings;
		var handler;
		if (typeof(options) !== 'string') {
		    settings = $.extend({}, defaults, options);
		    //do some quick and nasty fixes
		    settings.list_class = typeof(settings.list_class) === 'undefined' ? "" :
			settings.list_class;
		    settings._wname = WIDGET_NAME;
		    settings._wid = WIDGET_ID;
		    try {
		    	//bind the plugin handler to this
		    	return this.each(function() {
				    var $this = $(this);
				    // handler = new OrcidSearcher($this, settings);
				    bind_orcid_plugin($this, settings);
				});
		    }
		    catch (err) {  alert(err); }
		}
	}

	/**
	 * this function primarily will bind all the needed DOM onto the target input field
	 * @param  {object} obj      javascript object represent the input target field
	 * @param  {object} settings local settings of the jQuery plugin
	 * @return {void}            DOM modification
	 */
	function bind_orcid_plugin(obj, settings){

		//set obj.p as the parent, this parent is used throughout the plugin as a reference point
		if(obj.parent().is('span.inputs_group')){
			//important for local ANDS scripts inputs_groups element
			var p = obj.closest('.controls');
			obj.p = p;
		}else{
			//not in ANDS inputs_group wrapper, wrap it with defined wrapping
			obj.wrap(settings.wrap_html);
			var p = obj.parent();
			obj.p = p;
		}
		
		//init a lookup if settings told you to
		if(settings.pre_lookup || (obj.attr('data-autolookup')==='true')) _lookup(obj, settings);

		//use lookup
		if(settings.lookup){
			var lookup_btn = $('<button>').addClass(settings.lookup_class).html(settings.lookup_text);
			p.append(lookup_btn);
			$(lookup_btn).on('click', function(e){
				e.preventDefault();
				_lookup(obj, settings);
			});
		}

		//use settings
		if(settings.search){
			 
			var search_btn = $('<button>').addClass(settings.search_class).html(settings.search_text);
			var search_html = settings.query_text+' <input type="text" class="orcid_search_input"/> <a class="search_orcid">'+settings.search_text_btn+'</a><div class="orcid_search_result"></div><a class="close_search">'+settings.close_search_text_btn+'</a>';
			var search_div = $('<div>').addClass(settings.search_div_class).html(search_html);

			if(!settings.pre_open_search) $(search_div).hide();
			p.append(search_btn).append(search_div);
			$(search_btn).on('click', function(e){
				e.preventDefault();
				_search_form(obj, settings);
			});
			$('input.orcid_search_input', p).on('keypress', function(e){
				//enter key
				if(e.keyCode==13){
					_search($(this).val(), obj, settings); return false;
				}
			});
			$('.search_orcid', p).on('click', function(e){
				//click orcid search
				e.preventDefault();
				e.stopPropagation();
				var query = $('.orcid_search_input', p).val();
				_search(query, obj, settings);
			});
			$('.close_search', p).on('click', function(){
				//close button
				$('.'+settings.search_div_class, p).slideUp();
			});
		}
		
		//before_html
		if(settings.before_html) obj.before(settings.before_html);

		$(obj).on('keypress', function(e){
			//enter key
			if(e.keyCode==13){
				_lookup(obj, settings); return false;
			}
		});
	}

	/**
	 * execute a look up functionality on the ORCID jsonp service
	 * @param  {object} obj      javascript object represent the target input field
	 * @param  {object} settings local settings of the jQuery plugin
	 * @return {void}            this will modify the DOM based on the return value
	 */
	function _lookup(obj, settings){
		var value = obj.val();
		$.ajax({
			url:settings.lookup_endpoint+encodeURIComponent(value)+'?callback=?', 
			dataType: 'jsonp',
			timeout: 1000,
			success: function(data){
				if(settings.lookup_success_handler && (typeof settings.lookup_success_handler === 'function')){
					//if there's a predefined handler, use it instead
					settings.lookup_success_handler(data, obj, settings);
				}else{
					_clean(obj, settings);
					var html = _constructORCIDHTML(data['orcid-profile'],settings);
					var result_div = $('<div>').addClass(settings.result_success_class).html(html);
					obj.p.append(result_div);
					if(settings.post_lookup_success_handler && (typeof settings.post_lookup_success_handler ==='function')){
						//if there's a hook defined, use it after success
						settings.post_lookup_success_handler(data,obj,settings);
					}
				}
			},
			error: function(xhr){
				if(settings.lookup_error_handler && (typeof settings.lookup_error_handler === 'function')){
					settings.lookup_error_handler(xhr);
				}else{
					_clean(obj, settings);
					var result_div = $('<div>').addClass(settings.result_error_class).html(settings.nohits_msg);
					obj.p.append(result_div);
					obj.addClass('error');
				}
			}
		});
	}

	/**
	 * construct a HTML string out from an ORCID object for display
	 * @param  {orcid['orcid-profile']} obj orcid-profile array of the returned object
	 * @return {string}     HTML string
	 */

	function _constructORCIDHTML(obj,settings) {

		var resStr = '';
		resStr += "<div class='"+settings.info_box_class+"'>"
		resStr += "<h6>ORCID Identifier</h6>";
		var orcid = eval(obj['orcid-identifier']);
		resStr += orcid.path;

		if(obj['orcid-bio']['biography'])
		{		    		
			if(obj['orcid-bio']['biography'].value!='')	
			{
				resStr += "<h6>Biography</h6>";
				var biography = obj['orcid-bio']['biography'].value		
				biography = biography.replace(/"/g,'&quot;');		
				resStr +="<p>"+biography+"</p>";
			}
		}
		    					    	
		if(obj['orcid-bio']['personal-details'])
		{
			resStr +="<h6>Personal Details</h6>"		 					    		
			resStr +="<p>";
				if(obj['orcid-bio']['personal-details']['credit-name'])
					resStr +="Credit name: "+obj['orcid-bio']['personal-details']['credit-name'].value+" <br />";
				if(obj['orcid-bio']['personal-details']['family-name']) 					    
					resStr +="Family name: "+obj['orcid-bio']['personal-details']['family-name'].value+" <br />"; 
				if(obj['orcid-bio']['personal-details']['given-names'])  					    
					resStr +="Given names: "+obj['orcid-bio']['personal-details']['given-names'].value+" <br />";
				if(obj['orcid-bio']['personal-details']['other-names'])
				{   					    		
					resStr +="Other names: ";
					var count = 0;	
					for(i=0; i< (obj['orcid-bio']['personal-details']['other-names'].length -1);i++)
					{
						resStr += obj['orcid-bio']['personal-details']['other-names']['other-name'][i].value + ", ";
						count++;
					}
						resStr += obj['orcid-bio']['personal-details']['other-names']['other-name'][count].value + "<br />";
				} 	
			}

			if(obj['orcid-bio']['keywords'])
			{ 					    		
				resStr +="<h6>Keywords</h6>"
				var count = 0;	
				for(i=0; i< (obj['orcid-bio']['keywords']['keyword'].length -1);i++)
				{
					resStr += obj['orcid-bio']['keywords']['keyword'][i].value + ", ";
					count++;
				}
				resStr += obj['orcid-bio']['keywords']['keyword'][count].value + "<br />"; 					    		
			}

			if(obj['orcid-bio']['researcher-urls'])
			{ 					    		
				resStr +="<h6>Research URLs</h6>"
				var count = 0;	
				for(i=0; i< (obj['orcid-bio']['researcher-urls']['researcher-url'].length -1);i++)
				{
					if(obj['orcid-bio']['researcher-urls']['researcher-url'][i].url.value!='')
						resStr += "URL : " + obj['orcid-bio']['researcher-urls']['researcher-url'][i].url.value + "<br /> ";
					if(obj['orcid-bio']['researcher-urls']['researcher-url'][i]['url-name'].value)
						resStr += "URL Name : " + obj['orcid-bio']['researcher-urls']['researcher-url'][i]['url-name'].value + "<br /> ";   					    			
					count++;
				}
				if(obj['orcid-bio']['researcher-urls']['researcher-url'][count].url)
				{
					if(obj['orcid-bio']['researcher-urls']['researcher-url'][count].url.value!='')
						resStr += "URL : " + obj['orcid-bio']['researcher-urls']['researcher-url'][count].url.value + "<br />";
				}
				if(obj['orcid-bio']['researcher-urls']['researcher-url'][count]['url-name'])
				{
					if(obj['orcid-bio']['researcher-urls']['researcher-url'][count]['url-name'].value!='')
						resStr += "URL Name : " + obj['orcid-bio']['researcher-urls']['researcher-url'][count]['url-name'].value + "<br />";   
				}				    		
			} 					    					    					    						    	
		resStr += "</div>"
		return resStr;
	}

	/**
	 * isset equivalent for javascript
	 * @param  variable something to check
	 * @return {boolean}       
	 */
	function isset(variable){
		if(typeof(variable) != "undefined" && variable !== null) {
		    return true;
		}else return false;
	}

	/**
	 * init a search request on the ORCID jsonp service
	 * @param  {string} query    search query
	 * @param  {object} obj      javascript object represent the input target field
	 * @param  {object} settings local settings of the plugin
	 * @return {void}            this will modify the DOM based on the search result
	 */
	function _search(query, obj, settings){
		var p = obj.p;
		var result_div = p.find('.'+settings.orcid_search_result);
		if($.trim(query)==""){
			$('.orcid_search_result', p).html('Please enter a search string');
		}else{
			$('.orcid_search_result', p).html('Loading...');
			$.ajax({
				url:settings.search_endpoint+encodeURIComponent(query)+'&start=0&rows=10&wt=json&callback=?', 
				dataType: 'jsonp',
				success: function(data){
					if(settings.success_handler && (typeof settings.success_handler === 'function')){
						settings.success_handler(data, obj, settings);
					}else{
						if(data['orcid-search-results']){
							var html='<ul>';
							$.each(data['orcid-search-results']['orcid-search-result'], function(){
								var titleStr = "";
								if(settings.tooltip) titleStr = 'title="'+_constructORCIDHTML(this['orcid-profile'],settings)+'"';
								var orcid = this['orcid-profile']['orcid-identifier'].path;
								var given = this['orcid-profile']['orcid-bio']['personal-details']['given-names'].value || '';
								var family = this['orcid-profile']['orcid-bio']['personal-details']['family-name'].value || '';
								html+='<li>';
								html+='<a class="select_orcid_search_result preview" '+titleStr+' orcid-id="'+orcid+'">'+given+' '+family+'</a>';
								html+='</li>';
							});
							html+='</ul>';
							$('.orcid_search_result', p).html(html);
						}else{
							$('.orcid_search_result', p).html(settings.nohits_msg);
						}
					}
					$('.select_orcid_search_result', p).on('click', function(){
						obj.val($(this).attr('orcid-id'));
						_lookup(obj, settings);
						if(settings.auto_close_search) _search_form(obj, settings);
					});
					if(settings.tooltip){
						$('.preview').each(function(){       
   								$(this).qtip({
       							 content: {
            						text: $(this).attr('title'),
            					},
       							position: {
           						 	my: 'left center',
          						  	at: 'right center',
           						 	viewport: $(window)
        						},
        						show: {
            						event: 'mouseover',
        						},
        						hide: {
            						event: 'mouseout'
        						},
        						style: {
            						classes: 'ui-tooltip-light ui-tooltip-shadow orcidPreview',
            						width: 550
       							 }
    							}); 
    					});
					}
				},
				error: function(xhr){
					if(settings.error_handler && (typeof settings.error_handler === 'function')){
						settings.error_handler(xhr);
					}else{
						console.error(xhr);
					}
				}
			});
		}
	}

	//remove (if exist) error and result
	function _clean(obj, settings){
		obj.removeClass('error');
		if(obj.p.children('.'+settings.result_error_class).length>0){
			obj.p.children('.'+settings.result_error_class).remove();
		}
		if(obj.p.children('.'+settings.result_success_class).length>0){
			obj.p.children('.'+settings.result_success_class).remove();
		}
	}

	//open the search form
	function _search_form(obj, settings){
		obj.p.children('.'+settings.search_div_class).slideToggle();
	}
	
	//catch all .orcid_widget and apply orcid_widget() with default settings on

	$('.orcid_widget').each(function(){
	   	var elem = $(this);
	   	var widget = elem.orcid_widget();
    });

})( jQuery );