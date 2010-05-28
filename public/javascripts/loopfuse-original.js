var _lf_cid = "";
var i = "";
var _lf_mydomain = "";
var _lf_doc = document;
var _lf_doc_title = _lf_doc.title;
var _lf_currpage = window.location.href;
var _lf_loopfusePageProtocol = window.location.protocol + "//";
var _lf_trackdomain = "lfov.net";
var _lf_loopfuseHomeURL = _lf_loopfusePageProtocol + _lf_trackdomain;
var _lf_recorder_path = "/webrecorder/w";
var _lf_loopfuseVIDURL = _lf_trackdomain + "/webrecorder/g/chimera.js";
var _lf_vid;
var _lf_kvid;
var _lf_kid = _lf_getURLParam("x_lf_kid");
var _lf_kt = _lf_getURLParam("x_lf_kt");
var _lf_kr = _lf_getURLParam("_x_lf_kr");
var _lf_cName = "LOOPFUSE";

function _lf_remora() {
    var _lf_trackURL = "";
    if (_lf_cid == undefined || _lf_cid == "") {
        return;
    }
    _lf_trackURL += _lf_loopfuseHomeURL + _lf_recorder_path;
    var _lf_ref = "&from=" + _lf_getReferer();
    var _lf_resolution = "&res=" + window.screen.width + "x" + window.screen.height;
    var _lf_title = "&t=" + escape(_lf_doc_title);
    var _vid = "&vid=" + _lf_getVID();
    var _lf_cp = "&cp=" + escape(_lf_currpage);
    var _campy;
    _lf_trackURL += "?cid=" + _lf_cid + _vid + _lf_ref + _lf_title + _lf_resolution + _lf_cp;
    if (_lf_kid != "" &&
        _lf_kid != undefined && _lf_kt != undefined && _lf_kt != "") {
        _campy = "&kid=" + _lf_kid + "&kt=" + _lf_kt;
    }
    if (_lf_kr != "" && _lf_kr != undefined) {
        _campy += "&kr=" + _lf_kr;
    }
    if (_lf_kvid != undefined && _lf_kvid != null && _lf_kvid != "") {
        _campy += "&kvid=" + _lf_kvid;
    }
    if (_campy != "" && _campy != undefined) {
        _lf_trackURL += _campy;
    }
    _lf_trackURL += "&" + Math.random();
    _lf_setCookie();
    var sentinel = new Image(1, 1);
    sentinel.border = 0;
    sentinel.src = _lf_trackURL;
    _lf_modForms();
}


function _lf_remora_tracker(_page, _red) {
    var _lf_trackURL = "";
    if (_lf_cid == undefined || _lf_cid == "") {
        return;
    }
    if (_page == undefined || _page == "") {
        return;
    }
    _lf_trackURL += _lf_loopfuseHomeURL + _lf_recorder_path;
    var _lf_this = "&from=" + _lf_doc.URL;
    var _lf_resolution = "&res=" + window.screen.width + "x" + window.screen.height;
    var _lf_title = "&t=" + escape(_lf_doc_title);
    var _vid = "&vid=" + _lf_getVID();
    var _lf_to = "&to=" + _page;
    _lf_trackURL += "?cid=" + _lf_cid + _vid + _lf_this + _lf_title + _lf_resolution + _lf_to;
    _lf_trackURL += "&" + Math.random();
    i = new Image(1, 1);
    i.src = _lf_trackURL;
    _lf_pause(1500);
    if (_red == undefined || _red == "") {
        window.location = _page;
    }
}


function _lf_pause(_lf_time_msec) {
    var _lf_now = new Date;
    var _lf_expire = _lf_now.getTime() + _lf_time_msec;
    while (_lf_now.getTime() < _lf_expire) {
        _lf_now = new Date;
    }
}


function _lf_getURLParam(name) {
    var value = "";
    var href = window.location.href;
    if (href.indexOf("?") > -1) {
        var queryString = href.substr(href.indexOf("?")).toLowerCase();
        var queryParams = queryString.split("&");
        for (var i = 0; i < queryParams.length; i++) {
            if (queryParams[i].indexOf(name + "=") > -1) {
                var aParam = queryParams[i].split("=");
                value = aParam[1];
                break;
            }
        }
    }
    return value;
}


function _lf_getGUID() {
    _lf_vid = _lf_getCookie(_lf_cName);
    if (_lf_vid == undefined ||
        _lf_vid == "" || _lf_vid == null || _lf_vid == "null") {
        if (_lf_kt == "2") {
            var tkvid = _lf_getURLParam("_x_lf_kvid");
            if (tkvid != undefined && tkvid != "" && tkvid != null) {
                _lf_vid = tkvid;
            }
        }
    } else {
        if (_lf_kt == "2") {
            var tkvid = _lf_getURLParam("_x_lf_kvid");
            if (tkvid != undefined && tkvid != "" && tkvid != null) {
                if (_lf_vid != tkvid) {
                    _lf_kvid = tkvid;
                }
            }
        }
    }
    _lf_processCookie(_lf_vid);
}


function _lf_processCookie(thevid) {
    _lf_loopfuseVIDURL = _lf_loopfuseVIDURL + ("?vid=" + thevid);
    document.write("<SCR" + "IPT TYPE='text/javascript' SRC='" + "http" + (window.location.protocol.indexOf("https:") == 0 ? "s" : "") + "://" + _lf_loopfuseVIDURL + "'></SCR" + "IPT>");
}


function _lf_genCookieID() {
    _lf_gk = _LFC4() + _LFC4() + ("-" + _LFC4() + "-" + _LFC4() + "-" + _LFC4() + "-" + _LFC4() + _LFC4() + _LFC4());
    return _lf_gk;
}


function _LFC4() {
    return ((1 + Math.random()) * 65536 | 0).toString(16).substring(1);
}


function _lf_setCookie() {
    var date = new Date(2020, 1, 1);
    var expires = ";expires=" + date.toGMTString();
    var _lf_domain = _lf_getDomain();
    var path = "/";
    document.cookie = _lf_cName + ("=" + escape(_lf_vid) + (expires ? ";expires=" + expires : "") + (path ? ";path=" + path : "") + (_lf_domain ? ";domain=" + _lf_domain : ""));
}


function _lf_getVID() {
    if (_lf_vid == undefined ||
        _lf_vid == "" || _lf_vid == null || _lf_vid == "null") {
        _lf_vid = _lf_genCookieID();
    }
    return _lf_vid;
}


function _lf_getCookie(name) {
    var dc = document.cookie;
    var prefix = name + "=";
    var begin = dc.indexOf("; " + prefix);
    if (begin == -1) {
        begin = dc.indexOf(prefix);
        if (begin != 0) {
            return null;
        }
    } else {
        begin += 2;
    }
    var end = document.cookie.indexOf(";", begin);
    if (end == -1) {
        end = dc.length;
    }
    return unescape(dc.substring(begin + prefix.length, end));
}


function _lf_getDomain() {
    var _lf_domain;
    if (_lf_mydomain == "" ||
        _lf_mydomain == undefined ||
        _lf_mydomain == null || _lf_mydomain == "null") {
        _lf_mydomain = _lf_doc.domain;
        if (_lf_mydomain.substring(0, 4) == "www.") {
            _lf_domain = _lf_mydomain.substring(4, _lf_mydomain.length);
        } else {
            var e = _lf_mydomain.split(/\./);
            if (e.length > 1) {
                _lf_domain = "." + e[e.length - 2] + "." + e[e.length - 1];
            }
        }
        return _lf_domain;
    } else {
        return "." + _lf_mydomain;
    }
}


function _lf_getReferer() {
    var _lf_ref = escape(_lf_doc.referrer);
    if (_lf_ref == undefined || _lf_ref == "") {
        return "";
    }
    return _lf_ref;
}


function _lf_modForms() {
    var _forms = _lf_doc.getElementsByTagName("form");
    for (var i = 0; i < _forms.length; i++) {
        var _objForm = _forms[i];
        var inputV = document.createElement("input");
        inputV.type = "hidden";
        inputV.name = "vid";
        inputV.value = _lf_vid;
        _objForm.appendChild(inputV);
        var inputC = document.createElement("input");
        inputC.type = "hidden";
        inputC.name = "lf_cid";
        inputC.value = _lf_cid;
        _objForm.appendChild(inputC);
    }
}

_lf_getGUID();
