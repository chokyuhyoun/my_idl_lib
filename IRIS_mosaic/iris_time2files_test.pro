function iris_time2files, t0, t1, drms_out, level=level, prelaunch=prelaunch, _extra=_extra, parent=parent, $
   sji=sji, nuv=nuv, fuv=fuv, no_hours=no_hours, only_parent=only_parent, urls=urls, prelim=prelim, $
   obsdirs_only=obsdirs_only, obsid=obsid, raster=raster, log=log, interactive=interactive, $
   jsoc=jsoc, drms=drms, xquery=xquery, loud=loud, prepped=prepped,key_jsoc=key_jsoc, all_jsoc=all_jsoc, $
   test=test, js2=js2, nrt=nrt, compressed=compressed, $
   sot=sot,sdo=sdo,aia=aia
;
;   Name: iris_time2files
;
;   Purpose: nomial time-range + level -> filelist (eventually url_list)
;
;   Input Parameters:
;      t0,t1 - time range of interest
;
;   Output:
;      function returns file list matching time/level/pattern...
;
;   Output Parameters:
;      drms_out - optional drms meta data out - (implies /JSOC  ) 
;
;   Keyword Parameters:
;      _extra - inherit -> ssw_time2filelist
;      prelaunch - switch to select 'prelaunch' area (yes, I've thought about using T0 for this ,but decided against it...)
;      no_hours - set this if for some reason Your tree does not include the "hours" branch /H00hh/
;       sji,nuv,fuv - optional iris isntr switches (pattern -> ssw_time2filelist)
;      only_parent - if set, just construct implied PARENT directory and return That instead of file list
;      urls - if set, search iris http server (lmsal for now)
;      obsdirs_only - if set, only return the <path>/yyyyyyyy_hhmmss_<10 digit obs id>/ (level 2 only for today)
;      obsid - optional OSBID filter (level2 and higher only)
;      interactive - switch - if set, present menu selection after filters applied (L2 and > only)
;      jsoc - switch - if set, deterministic filenames/urls derived from drms meta data + $IRIS_DATA
;      xquery - optional XQUERY -> ssw_jsoc_time2data (implies /jsoc)
;      level - data level
;      loud (switch) - if set, be more verbose
;      key_jsoc - optional list of jsoc keys to include (in drms_out) (-> ssw_jsoc_time2data)
;      all_jsoc - returns All jsoc meta for input DS (takes longer - default is minimal set to derive filenames for speed)
;      prelim - optional prelim level to use (example  ,prelim=4  implies .../level_prelim04 )
;      test - if switch (/test), implies $IRIS_DATA/levelN_test/levelN_<today>/stuff>
;             if date, then $IRIS_DATA/levelN_yyyymmdd/<stuff>
;      js2 (switch) - if set, use JSOC2 urls (need firewall permission per Phil@jsoc) - for "unpublished" series.
;                     (a little shore-sightedly, I used /JSOC to use jsoc sql so /JSOC2 would have clobbered that - hence, /JS2)
;      nrt (switch) - if set, force _nrt (default for "recent" time ranges)
;      sot,sdo,aia - if set, iris/"Martin" style L2 cubes (for LEVEL=2 only)
;
;   Method:
;      setup & call generic ssw_time2filelist.pro with some IRIS specific value added
;
;   Calling Sequence:
;      IDL> files=iris_time2files(t0,t1,level=level [,/jsoc ] [,prelim=N] )
;
;   History:
;      22-apr-2013 - S.L.Freeland
;      30-jul-2013 - S.L.Freeland - added /OBSDIRS_ONLY keyword & function
;      12-aug-2013 - S.L.Freeland - sped up Level2 , add OBSID keyword and function
;                                   add /JSOC & /DRMS (synonyms)
;      26-aug-2013 - S.L.Freeland - add drms_out output parameter
;       2-sep-2013 - S.L.Freeland - prelim03 support
;       3-sep-2013 - S.L.Freeland - 1p5 support - ignore prelim01/02
;     16-sep-2013  - S.L.Freeland - fix silly hours->hour in call to ssw_time2filelist
;                                   include instrume in XQUERY if /jsoc & one of instrument switches set
;                                   require IMG_TYPE in minimal keyword set (darks etc)
;     18-sep-2013  - S.L.Freeland - added PRELIM=N keyword & function ; default is 3 as of now, maybe 4 on Monday...
;     23-sep-2013  - S.L.Freeland - tweak for All permutaions={with/withough $IRIS_DATA} x {with/without /JSOC} x {with/without /URLS}
;     27-sep-2013  - S.L.Freeland - level2 local; kind of a kludge, but works and x10 faster....
;      1-oct-2013  - S.L.Freeland - add TEST keyword and function.
;      5-dec-2013  - S.L.Freeland - add COMPRESSED keyword & function (level=2)
;      9-jan-2014  - S.L.Freeland - require explicit /NRT (remove "recent data" default)
;      6-feb-2018  - S.L. Freeland - add /SDO & /SOTFG (and a few synonyms) keywords & function
;     13-mar-2020 - R. Timmons - add https force for coming LMSAL webserver changes.
;-
;      
loud=keyword_set(loud)
url_parent='https://www.lmsal.com/solarsoft/' ; vector
urls=keyword_set(urls)

case 1 of  
   n_elements(t0) eq 0 and n_elements(t1) eq 0: begin  
         t0=reltime(days=-2,/day_only)
         t1=reltime(/days,/day_only)
   endcase
   n_elements(t1) eq 0:  t1=reltime(t0,/days,/day_only)
   else: ; user supplied range
endcase
irisdata=get_logenv('IRIS_DATA')
if not file_exist(irisdata) then irisdata='/archive/iris/data'
if urls then irisdata='/irisa/data'

pl=keyword_set(prelaunch)
iristop=irisdata + (['','/prelaunch'])(pl)
if get_logenv('check_iris') ne '' then stop,'iristop'
if keyword_set(prepped) then level=1.5 
if n_elements(level) eq 0 then level=1 ; default=Levels
pl=''

dlev=strtrim(level,2)
testing=keyword_set(test)

;if n_elements(prelim) eq 0 then prelim= ([3,4])(testing) ; preliminary version

if level eq 1.5 then dlev='1p5' ; special case 

dt0=ssw_deltat(t0,ref='8:49 22-oct-2013',/hours)
;if n_elements(nrt) eq 0 then nrt=ssw_deltat(t0,reltime(/now),/days) le 3 
nrt=keyword_set(nrt) ; 9-jan-2014 - removed above time based (somewhat arbitrary) default
case 1 of 
   keyword_set(prelim): pl=(['_prelim'+string(prelim,format='(i2.2)'),'_test'])(testing)
   nrt and level le 1.5: pl='_nrt'
   nrt and level eq 2: pl='_nrt'
   keyword_set(test): pl='_test'
   keyword_set(compressed) and level eq 2: pl='_compressed'
   else:
endcase



testlev=''
delvarx,test
if n_elements(test) ne 0 then begin 
   vtemp='yyyymmdd' ; daily
   case 1 of 
      data_chk(test,/string): begin
         if strlen(test) eq strlen(vtemp) then dstring=test else $
            dstring=strmid(time2file(test),0,strlen(vtemp))
      endcase
      else: begin
         dstring=time2file(reltime(/now,/day_only),/date_only)
      endcase
   endcase
   testlev='/level'+dlev+'_'+dstring
endif

slev='/level'+ dlev + pl + testlev

;RPT shutting down all earth specific things
;case 1 of ; local glue to handle archive move/transistion - email me if this is still here in 2014... 
;   urls or file_stat(concat_dir(iristop,'is_earth')):  ; ok, don't f with it
;   dlev eq '1p5' and pl eq '_nrt' and ssw_deltat(t0,ref='13:00 24-oct-2013',/hour) ge 0 : iristop='/Volumes/earth/iris/data/'
;   dlev eq '1' and pl eq '_nrt' and ssw_deltat(t0,ref='13:00 28-oct-2013',/hour) ge 0 : iristop='/Volumes/earth/iris/data'
;   else:
;endcase


if not file_exist(parent) then parent=iristop+slev

box_message,'Parent>> ' + parent[0]

sji=keyword_set(sji)
nuv=keyword_set(nuv)
fuv=keyword_set(fuv)
sdo=keyword_set(sdo) or keyword_set(aia)
sot=keyword_set(sot) or keyword_set(sotfg) ; need check when sotsp available

if n_elements(xquery) eq 0 then xquery=''
if keyword_set(only_parent) then begin 
   retval=parent

endif else begin 

   tx0=anytim(t0,/ecs)
   tx1=anytim(t1,/ecs)
   count=0 ; as with life, assume failure
   if n_elements(pattern) eq 0 then pattern=''
   if keyword_set(obsid) then pattern='*'+strtrim(obsid,2)+'*'
   case 1 of 
      sji: begin 
         pattern=pattern+'*sji*'
         instrume='SJI'
      endcase
      nuv: begin 
         pattern=pattern+'*nuv*'
         instrume='NUV'
      endcase
      fuv: begin 
         instrume='FUV'
         pattern=pattern+'*fuv*'
      endcase
      sdo: pattern='*SDO*'
      sot: pattern='*SOT*'
      keyword_set(raster): pattern=pattern+'*raster*'
      keyword_set(log): pattern=pattern+'*log'
      else:
   endcase
   if keyword_set(urls) then parent=url_parent+parent ; file->url vector
   if level eq 2 and keyword_set(obsdirs_only) and not urls then begin
      tpaths=ssw_time2paths(tx0,tx1,parent=parent,count=count)
      retval=''
      for p=0,count-1 do begin 
         obsx=findfile(tpaths[p])
         if obsx[0] ne '' then retval=[retval,concat_dir(tpaths[p],obsx)]
      endfor
      if n_elements(retval) eq 1 then box_message,'No Level2 for your time range' else begin
         retval=strarrcompress(retval)
         rtimes=anytim(file2time(retval))
         sst=where(rtimes ge anytim(t0) and rtimes le anytim(t1),tcnt)
         if tcnt eq 0 then begin
            box_message,'Some OBSDIRS on these dates, but none within your time range'
            retval=''
         endif else retval=retval[sst]
      endelse
   endif else begin 
      if level eq 2 then begin 
         if urls then begin
            retval=iris_time2urls_l2(tx0,tx1,obsdirs_only=obsdirs_only,pattern=pattern, parent=parent)
         endif else begin 
            ;obsdirs=iris_time2files(tx0,tx1,/obsdirs,level=2,prelim=prelim)
            ;retval=file_search(obsdirs,'')
            retval=iris_time2urls_l2(tx0,tx1,obsdirs_only=obsdirs_only,parent=url_parent+parent)
            retval=ssw_strsplit(retval,url_parent,/tail) ; kind of a kludge but much faster than the file_search option...
         endelse
         if retval[0] eq '' then box_message,'No level 2 files within your time range else begin 
            if keyword_set(pattern) then begin 
              ss=where(strmatch(retval,pattern,/fold),pcnt)
              if pcnt eq 0 then begin 
                 box_message,'Files in your time range but none matching pattern'
                 retval=''
              endif else begin
                 retval=retval[ss]
              cpatts=str2arr('sdo,aia,sotfg,sotsp,sot')
              if is_member(pattern,'*'+cpatts+'*',/ignore_case) then begin 
                 for p=0,n_elements(cpatts)-1 do retval=str_replace(retval,cpatts[p],strupcase(cpatts[p]))
              endif
              endelse
            endif
                 if keyword_set(interactive) and retval[0] ne '' then begin 
                    tlf=iris_files2timeline(retval)
                    info=get_infox(tlf,'date_obs,date_end,obsid,filename,description')
                    ss=xmenu_sel(info)
                    retval=retval[ss]
                 endif
         ; endelse
      endif else begin 
          drms=keyword_set(drms) or keyword_set(jsoc) or keyword_set(xquery) or n_params() gt 2
          if drms then begin 
              print, '0'
             if total(strmatch(xquery,'*instrume*',/fold)) eq 0  and keyword_set(instrume) then begin 
              print, '1'
                xinstr='INSTRUME="'+instrume+'"'
                if xquery(0) eq '' then xquery=xinstr else xquery=[xquery,xinstr]
             endif
             if total(strmatch(xquery,'*ISQOLTID*',/fold)) eq 0  and keyword_set(obsid) then begin 
              print, '2'
                xobs='ISQOLTID='+strtrim(obsid,2)
                if xquery(0) eq '' then xquery=xobs else xquery=[xquery,xobs]
             endif
             ds=(['iris.lev0','iris.lev1'+pl])(floor(float(level)))
             min_key='T_OBS,INSTRUME,IMG_PATH,IMG_TYPE' ; minimal jsoc meta required for filename derivation
             case 1 of 
                n_elements(key_jsoc) eq 1 : key_jsoc=arr2str(all_vals([str2arr(key_jsoc),str2arr(min_key)])) 
                keyword_set(all_jsoc): delvarx,key_jsoc  ; user wants All jsoc metadata
                else: key_jsoc=min_key ; default is minimal set for speed->filenames
             endcase
             ssw_jsoc_time2data,tx0,tx1,ds=ds,drms_out,key=key_jsoc,jsoc2=js2,xquery=xquery,_extra=_extra, silent=(1-loud) 
             stop 
             retval=iris_index2filenames(drms_out, level=level,prelim=prelim,urls=urls, nrt=nrt) ; deterministic meta -> $IRIS_DATA/<level>/yyyy/mm/dd/Hhhhh/<files>
             if keyword_set(urls) and strpos(retval[0],'http') eq -1 then retval=url_parent + retval
         endif else begin
            box_message,'pre time2filelist, parent='+parent
            retval=ssw_time2filelist(tx0,tx1,parent=parent, _extra=_extra, pattern=pattern, count=count, hour=1-keyword_set(no_hours))
         endelse
      endelse
   endelse
endelse

return,retval
end


