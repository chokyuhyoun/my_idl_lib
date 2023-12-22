pro ssw_jsoc_time2data, t0, t1, index, data , ds=ds, _extra=_extra, $
   serstr=serstr, filter=filter, menu=menu, lastn=lastn, $
   exp_request=exp, locfiles=locfiles, outdir_top=outdir_top, $ 
   segment=segment, parent_out=parent_out, $
   minutes=minutes, hours=hours, keywords=keywords, $
   files_only=files_only, urls_only=urls_only, outsize=outsize, local_files=local_files, $
   quiet=quiet, silent=silent, dummy=dummy, max_files=max_files, waves=waves, $
   only_tags=only_tags, copy_only=copy_only, get_data=get_data, $
   no_jsoc_tags=no_jsoc_tags, $
   cadence=cadence, units_cadence=units_cadence, $
   fnames_uncomp=fnames_uncomp, fnames_comp=fnames_comp, $
   progress=progress, $
   uncomp_outdir=uncomp_outdir, comp_outdir=comp_outdir, $
   ucomp_parent=uncomp_parent,  comp_parent=comp_parent, $
   uncomp_delete=uncomp_delete, comp_delete=comp_delete, $
   xquery=xquery, tai=tai, jsoc2=jsoc2, struct_wherex=struct_wherex, $
   disable_primekey_logic=disable_primekey_logic, $
   harpnum=harpnum, fsn_in=fsn_in, $
   count=count, nmissing=nmissing
   
;+
;   Name: ssw_jsoc_time2data
;
;   Purpose: ssw times -> JSOC -> SSW "index,data" - time based derivation of ssw_last_jsoc.pro
;
;   Input Parameters:
;      t0,t1 - user time range
;   
;   Keyword Paramters:
;      ds - data series name
;      serstr - series structure (optional; will  derive otherwise)
;      lastn - optionally, most recent LASTN hours (or minutes if /MINUTES set)
;      local_files - if set, assume JSOC/DRMS is Local (ssw_jsoc_files2data.pro)
;      keywordss - optional list of desired KEYS
;      exp_request (output) - only defined if 4 params(export request) - exp_request structure
;      OUTDIR_TOP - if files written->local, desired local parent 
;      parent_out - synonym for OUTDIR_TOP keyword 
;      copy_only - if set, export & transfer but no immediate read
;      get_data - index/meta vector of desired records - 
;      keywords - optional list of one or more desired keywords vector string or comma delimited string scalar
;      only_tags - synonym for KEYWORDS for consistency with read_sdo (mreadfits_header...) ONLY_TAGS keyword
;      no_jsoc_tags - (switch) - if set, exclude JSOC bookeeping tags from ouput (COUNT/RUNTIME/STATUS)
;      locfiles (output) - local file names post transfer (decompressed if orignal is tile compressed
;      max_files - Throttle on maximum number of files 
;      cadence - temporal grid size (in conjunction w/UNITS_CADENCE) -or- verbatim string like '120m'
;      units_cadence - h(ours), m(inutes), or s(econds)
;      progress (switch) - if set and graphics terminal, track download progress (-> sock_copy.pro)
;      UNCOMP_DELETE (switch)  - if set, remove UnCompressed files after reading
;      COMP_DELETE   (switch)   - if set, remove Compressed files after reading
;      segment - segment number or segment name/substring (default=0) - for multi-seg series
;      xquery - optional user verbatim jsoc queries (will be appended)
;      jsoc2 - faster, so use this switch if Your machine has jsoc2 access privs (ask Phil to add you)
;      disable_primekey_logic - in conjunction with XQUERY, use !<blah>! instead of ?<blah>?
;      fsn_in (switch) - if set, input "times" are FSN
;      count (output) - number of drms records or files/urls returned
;      nmissing (output) - number of missing FILES (undefined if only 3 parameters)
;      harpnum - optional HARPNUM (assumes DS = one of the many *harp* series)
;      noaa - optional NOAA AR number (generally only for *harp* series  
;
;   Calling Sequence:
;      IDL> ssw_jsoc_time2data,t0,t1,index,DS=<seriesname>
;      IDL> ssw_jsoc_time2data,xx,yy,lastn=minutes,/minute,index [,/data,max_files=maxfiles], DS=<seriesname>
;
;   Calling Examples:
;
;      IDL> ssw_jsoc_time2data,'12:00 10-jun-2010','13:45 10-jun-2010',index, KEY='wavelnth,exptime,img_type,t_obs,date__obs'
;
;      IDL> ssw_jsoc_time2data,'15-dec-2011','17-dec-2011',drms,urls,/urls_only,cadence='1h',waves='171,193,304',/jsoc2
;
;   History:
;      6-mar-2009 - S.L.Freeland - time mapping->JSOC "index[,data]"
;      8-mar-2010 - S.L.Freeland - add hook for compressed JSOC files (->mreadfits_tilecomp.pro)
;  Early-jun-2010 - S.L.Freeland - post launch/real world enhancments; like PROTOCOL=FITS, GET_DATA...
;      9-jul-2010 - S.L.Freeland - merged some stuff, abort on series not found
;      6-aug-2010 - S.L.Freeland - add CADENCE & UNITS_CADENCE keywords (->ssw_jsoc_time2query)
;     30-aug-2010 - S.L.Freeland - add /PROGRESS, /UNCOMP_DELETE, and /COMP_DELETE keywords 
;      9-sep-2010 - S.L.Freeland - enhance/document SEGMENT keyword
;     22-sep-2011 - S.L.Freeland - rationalize XQUERY a bit - still some unknowns@jsoc re:general queries
;     17-may-2012 - S.L.Freeland - if DS not supplied, auto select "best" series for WAVES+epoch
;                                  preferentailly used Slotted series if available 
;                                  especially useful if CADENCE is supplied
;                                  explicitly added /JSOC2 switch (faster, if you have access priv)
;      6-nov-2012 - S.L.Freeland - additional naxis1/naxis2 (not in DRMS-only modes)
;      7-jun-2013 - S.L.Freeland - ditto preceding for IRIS
;     14-aug-2013 - S.L.Freeland - inhibit time_window for FSN_ONLY series
;     12-dec-2013 - S.L.Freeland - filter out non-existant FILES (moved to Tape?) - add COUNT keyword
;      4-sep-2014 - S.L.Freeland - some *harp* hooks (or series where time-primekeys are last,
;                                  not first primekey
;     10-oct-2014 - S.L.Freeland - skip file check if DATA alredy defined 
;     15-oct-2014 - S.L.Freeland - if SEGMENT supplied, force uniq match
;
;   Restrictions:
;      Not all PRIMEKEY combos are handled 
;   NOTES:
;      Caveat Emptor: This routine is a potential disk killer...
;      Optionally use /UNCOMP_DELETE and/or /COMP_DELETE to cleanup unwanted files 
;
;   Suggestions:
;      once you have a series struct SERSTR (either via ssw_jsoc or via output call to This program)
;      Passing it in via SERSTR=SERSTR will speed things up a abit
;      Use of KEYWORDS will speed up query & json->struct pieces - so use that if you  only need
;      a known subset of  key/pararmsf
;      Suggest use of MAX_FILES is you are asking for DATA and don't know
;      how much to expect...
;-

progress=keyword_set(progress) and is_member(!d.name,'X')
quiet=keyword_set(quiet) or keyword_set(silent)
silent=quiet
loud=1-silent
interactive=keyword_set(interactive)
if n_elements(ds) eq 0  then begin 
   if data_chk(serstr,/struct) then $
      ds=ssw_strsplit(serstr.interval.firstrecord,'[',/head) else begin
         box_message,'No data series supplied, guessing via WAVES
         if n_elements(waves) eq 0 then waves='171' ; 
         swave=(str2arr(strtrim(waves,2)))(0)
         ds=ssw_jsoc_wave2ds(swave,t0,jsoc2=js2)
         if n_elements(jsoc2) eq 0 then jsoc2=js2
         box_message,'DS='+ds 
      endelse
endif   


if not data_chk(serstr,/struct) then begin ; need SERIES STRUCTURE before proceding...
   if loud then box_message,'/SERIES_STRUCT, ds='+ds
print, 'OK'
stop
   serstr=ssw_jsoc(ds=ds,/SERIES_STRUCT,status=status,_extra=_extra,jsoc2=jsoc2)
   if not status then begin 
      box_message,'JSOC reported error, series='+ds+' ...aborting'
      return ;!! EARLY Exit on JSOC Error
   endif
endif

interval=gt_tagval(serstr,/interval)
allpk=all_vals(gt_tagval(serstr,/primekeys))
fsn_only=(n_elements(allpk) eq 1 and allpk[0] eq 'FSN')

if not fsn_only then time_window,ssw_time2jsoc([interval.firstrecord,interval.lastrecord],/jsoc2time), ds0,ds1

if keyword_set(lastn) then begin
   hours=1-keyword_set(minutes)
   lastdt=-1*abs(lastn) ; lookback
   t1=ds1
   if n_elements(minutes) then t0=reltime(ds1,minutes=minutes*lastdt) else $
      t0=reltime(ds1,hours=hours*lastdt) 
endif

if n_params() lt  3 then begin 
   box_message,"No output params specified so I won't waste your time and mine"
   return ; !! early exit
endif

fsn_in=keyword_set(fsn_in) or (fsn_only and total(strspecial(strtrim(t0,2))) eq 0)
harp_in=keyword_set(harp_in)

if keyword_set(fsn_in) then begin 
   query=ssw_jsoc_fsn2query(t0,t1,lastn=lastn,ds=ds,serstr=serstr)

endif else begin 
   if n_elements(t0) eq 0 then t0=reltime(t0,/days)  ; 24 hours

   t0x=anytim(t0,/ecs) & t1x=anytim(t1,/ecs)  ; rationalize formats
   if 1-fsn_only then begin
   if anytim(ds0) gt anytim(t1x) or anytim(ds1) lt anytim(t0x) then begin 
      box_message,'No records for this data sets within your time range'
      box_message,'Valid range= ' + arr2str([ds0,ds1],' -To- ')
      return
   endif
   endif


;  have time window; make a JSCOC style query string
   ut=strpos(interval.firstrecord,'_UT') ne -1
   tai=strpos(interval.firstrecord,'_TAI') ne -1 or keyword_set(tai)
   ccsds=strpos(interval.firstrecord,'Z') ne -1 and (1-tai)
   query=ssw_jsoc_time2query(t0x,t1x,ds=ds,$
      cadence=cadence, units_cadence=units_cadence, tai=tai,ut=ut,ccsds=ccsds, fsn_only=fsn_only) ; SSW times -> JSOC  query string
   if loud then box_message,'ssw_jsoc_time2query output: ' + query
endelse ; end of time input -> query


; now do the RS_LIST (includes calls to keywords->IDL structure, list, json->IDL
query=query(0)
if keyword_set(waves) and is_member('WAVELNTH',serstr.primekeys) then begin 
   box_message,'WAVELNTH added to query
   query=query+'['+arr2str(strtrim(waves,2))+']'
endif

if keyword_set(harpnum) then xquery='HARPNUM='+strtrim(harpnum,2)

if keyword_set(xquery) then begin
   disable_primekey_logic=keyword_set(disable_primekey_logic)
   delim=(['?','!'])(disable_primekey_logic)
   if loud then box_message,'Adding user verbatim query extensions
   xq='[' + delim + strtrim(xquery,2) + delim + ']'
   query=query+arr2str(xq,'')
   if get_logenv('xquery') ne '' then stop,'query,xquery'

endif
;

; segment check
segs=gt_tagval(serstr,/segments,missing='')
if n_elements(segs) gt 1 then begin 
   ; segment handling - check for user selection
   msegs=n_elements(segs)-1
   snames=strlowcase(segs.name)
   case 1 of 
      n_elements(segment) eq 0: segss=0
      data_chk(segment,/string):begin 
         segss=where(strpos(snames,strlowcase(segment(0))) ne -1,scnt)
         segss=segss[0] ; force scalar
         if scnt eq 0 then begin 
            box_message,'Unrecognized SEGMENT> ' +segment(0) + ' .. using first'
            segss=0
         endif
      endcase
      else: segss=segment(0) > 0 < msegs
   endcase
   imageseg=segs(segss).name
   if loud then box_message,'selecting segment> ' +  imageseg 
   query=query+'{'+imageseg+'}'
endif

if loud then box_message,'/rs_list, ds='+query
if keyword_set(only_tags) then keywords=only_tags ; synonym
if n_elements(keywords) ne 0 then begin
   keys=strupcase(keywords)
   if n_elements(keys) eq 1 then keys=str2arr(keys)
   keys=strtrim(keys,2)
   allkw=strupcase(serstr.keywords.name)
   valid=where_arr(keys,allkw,vcount)
   case 1 of
      vcount eq 0: begin 
         box_message,'None of your specified KEYWORDS found in this series... returning'
         return ; !!! early/error exit
      endcase
      vcount lt n_elements(keys): box_message,'At least one of your KEYWORDS not defined for this series
      else: valid=indgen(vcount)
   endcase
   keys=keys(valid) 
   index=ssw_jsoc(ds=query,/rs_list,key=arr2str(keys),jsoc2=jsoc2, _extra=_extra,xquery=xquery)
endif else index=ssw_jsoc(ds=query,/rs_list,jsoc2=jsoc2, _extra=_extra,xquery=xquery) ; metadata -> SSW "index"

if not data_chk(index,/struct) then begin 
   box_message,'No records, so bailing...
   return
endif
; clean trailing slashes which 
if gt_tagval(index(0),/telescop,missing='') ne '' then $
   index.telescop=str_replace(index.telescop,'\','')

if tag_exist(index,'date__obs') and not tag_exist(index,'date_obs') then $
   index=add_tag(index,index.date__obs,'date_obs') 

if ~tag_exist(index,'date_obs') and tag_exist(index,'t_rec') then $
   index=add_tag(index,ssw_time2jsoc(index.t_rec,/jsoc2time),'date_obs')


; 
if keyword_set(waves) and (strpos(ds,'_nrt2') ne -1 or strlowcase(ds) eq 'aia.lev1') then begin 
   wss=struct_where(index,search=['wavelnth='+arr2str(waves)],count,quiet=quiet) ; 'img_type=LIGHT'],count)
   if count eq 0 then begin
      box_message,'No files matching your waves list> +arr2str(waves)
      return
   endif
   index=index(wss)
endif

; if 4th parameter present, user wants the data (ssw_jsoc,/EXPORT)
nout=n_elements(index)

local_files=keyword_set(local_files) or $
   get_logenv('sums_local') ne '' and n_params() ge 4
urls_only=keyword_set(urls_only) 
files_only=keyword_set(files_only) ; or local_files


if n_params() ge 4 and data_chk(index,/struct) then begin ; a FETCH request
if get_logenv('check') ne ''  then stop,'pre export, index'
   if loud then box_message,'/export, ds='+query
   if urls_only or files_only then begin 
      box_message,'query -> files/urls'
      data=ssw_jsoc_query2sums(query,urls=urls_only,jsoc2=jsoc2)
      if n_elements(wss) gt 0 then data=data(wss)
   endif else begin ; /export -> jsoc_fetch 
   exp=ssw_jsoc(ds=query,/export,jsoc2=jsoc2, _extra=_extra,xquery=xquery) ; <<< SSW_JSOC /EXPORT
   if get_logenv('check') ne '' then stop, 'post export'
   if required_tags(_extra,'protocol') then begin 
      box_message,'Waiting for export...
      while not required_tags(exp,'data') do begin 
         wait,1
         exp=ssw_jsoc(exp_status=exp,jsoc2=jsoc2, _extra=_extra)
         box_message,'...'
      endwhile
   endif
   if not data_chk(exp,/struct) then begin
      box_message,'Problem with EXPORT...
      return ; !!!! early exit
   endif
   data=gt_tagval(exp,/data,missing='')
   if n_elements(imageseg) gt 0 then begin 
      box_message,'segment subselect'
      sss=where(strpos(data.record,imageseg) ne -1, scnt)
      data=data(sss)
   endif
   if n_elements(waves) gt 0 and n_elements(wss) gt 0 then begin ; WAVELNTH is not a primekey
      data=data(wss) ; wave subset
   endif
   if n_elements(sss) gt 0  or n_elements(wss) gt 0 then exp=rep_tag_value(exp,data,'data') ; reduced request

   jsoc_url=get_logenv('jsoc_url')
   if strpos(jsoc_url,'http') ne -1 then topurl=jsoc_url else $
      topurl='http://jsoc.stanford.edu'
   files=str_replace(exp.data.filename,'\/','/')
   urls=topurl+'/'+files
   files=files(where(strpos(files,'fits') ne -1,fcnt))
   if fcnt ne nout then begin 
      box_message,'TODO: index/data align'
      nout=fcnt
   endif
   if strpos(files(0),'SUM') ne -1 then files=str_replace(files,'\','') else $
      files=concat_dir(str_replace(exp.dir,'\',''),files)
   if keyword_set(max_files) then begin
      if max_files lt n_elements(index) then begin 
          box_message,'Throtteling to MAX_FILES'
          locfiles=last_nelem(files,max_files)
          files=last_nelem(files,max_files)
          index=last_nelem(index,max_files)
          urls=concat_dir(topurl,files)
          nout=max_files
       endif
   endif
   locfiles=files
   case 1 of 
      files_only or local_files: begin
         data=files
         if local_files then read_sdo,files,ii,data,_extra=_extra, comp_delete=comp_delete, uncomp_delete=uncomp_delete
if get_logenv('read_check') ne '' then stop,'index,ii'
         
      endcase
      urls_only: data=urls
      ; local_files: data=ssw_jsoc_files2data(files)  ; Uses memory mapped SUMS reads
      else: begin 
      if n_elements(parent_out) gt 0 then outdir_top=parent_out(0) ;synonym
      if n_elements(outdir_top) eq 0 then outdir_top=curdir()
      if not write_access(outdir_top) then outdir_top=get_temp_dir()
      locfiles=concat_dir(outdir_top,files)
      break_url,urls,ip,paths,fnames
      outdirs=concat_dir(outdir_top,paths)
if get_logenv('check') ne '' then stop,'locfiles'
      for i=0,nout-1 do begin ; sock_copy OUT_DIR assumes scalar?    
         mk_dir,outdirs(i)
         if loud then box_message,'Getting> '+urls(i)
         sock_copy,urls(i),out_dir=outdirs(i), progress=progress
      endfor
      if total(file_exist(locfiles)) eq nout then begin
          next=get_fits_nextend(locfiles(0))
          case 1 of 
             next eq 0: read_sdo,locfiles,dummy,data,outsize=outsize,_extra=_extra,fnames_uncomp=fnames_uncomp
             else: begin 
                htest=headfits(locfiles(0),ext=1)
                ctype=gt_tagval(htest,/zcmptype,missing='NONE')
                if n_elements(locfiles) gt n_elements(index) then begin 
                   ssimage=where(strpos(locfiles,'image_') ne -1,icnt)
                   if icnt eq n_elements(index) then locfiles=locfiles(ssimage)
                endif
                if get_logenv('check') ne '' then  stop,'locfiles
                case ctype of 
                   'NONE':  read_sdo,locfiles,dummy,data,outsize=outsize, parent_out=outdir_top, _extra=_extra, fnames_uncomp=fnames_uncomp
                   else: begin 
                      box_message,'Tile compressed data handling...
                      ;mreadfits_tilecomp, locfiles, index, data,/use_index , _extra=_extra
                      read_sdo,locfiles,index,data,/use_index,$
                         parent_out=outdir_top, _extra=_extra, fnames_uncomp=fnames_uncomp, uncomp_delete=uncomp_delete
                      fnames_comp=locfiles
                      if keyword_set(comp_delete) then begin 
                         if loud then box_message,'Removing compressed files on demand'
                         ssw_file_delete,locfiles
                         break_file,locfiles,lll,ppp,fff
                         ppp=ppp(uniq(ppp,sort(ppp)))
                         sssums=where(strpos(ppp,'SUM') ne -1,sumscnt) ; don't delete unexpected trees!
                         if sumscnt gt 0 then begin 
                            ppp=ppp(sssums)
                            sumsnum=strextract(ppp,'SUM','/')
                            sumshead=ssw_strsplit(ppp,'SUM',/head,tail=tail)
                            sumstop=sumshead+'SUM'+sumsnum
                            for dd=0,sumscnt-1 do file_delete,sumstop(dd),/quiet,/recursive  ; !! careful...
                         endif
                      endif
                   endcase
                endcase
             endcase
          endcase
          ;index=join_struct(dummy,temporary(index))
      endif else begin
         box_message,'not all files found...
      endelse
      endcase
   endcase
   endelse ; end of export/fetch 
   if local_files and data_chk(data,/string) and (1-files_only) then begin
      if file_exist(data(0)) then begin
         if n_elements(max_files) ne 0 then begin 
            data=last_nelem(data,max_files)
            index=last_nelem(index,max_files)
         endif
         files=data
         read_sdo,files,ii,data,_extra=_extra, comp_delete=comp_delete, uncomp_delete=uncomp_delete
if get_logenv('read_check') ne '' then stop,'index,ii'
         if n_tags(ii) ge n_tags(index) then index=ii ;else begin 
         ; endelse
      endif else if (1-urls_only) then box_message,'Local read request but file(s) not found...'
   endif
   if n_elements(data) gt 0 and (1-required_tags(index,'naxis1,naxis2')) then begin 
      index=add_tag(index,2,'naxis')
      dndim=data_chk(data,/ndimen)
      case dndim of
         2: begin 
            index=add_tag(index,data_chk(data,/nx),'naxis1')
            index=add_tag(index,data_chk(data,/ny),'naxis2')
         endcase
         0: 
         else: begin 
            iris=gt_tagval(index[0],/telescop,missing='') eq 'IRIS'
            lastchar=strlastchar(data)
            okss=where(lastchar eq 's' and file_exist(data),okcnt); fits
            badss=where(lastchar eq '/',nmissing) ; Not FITS - (moved to tape?)
            nd=n_elements(data)
            case 1 of 
               okcnt eq nd: ; NOP, all files/data exist
               okcnt gt 0: begin 
                  box_message,'A subset of files are not online, returning only online "index,files"
                  data=data[okss]
                  index=index[okss]
               endcase
               data_chk(data,/nim) gt 0: ; data read, NOP 10-oct-2014
               else: begin
if get_logenv('check_hmi') ne '' then stop,'okss,data'
                  if not keyword_set(urls_only) then begin 
                     box_message,'None of the files for this time range/param set are online
                     data=''
                  endif
               endcase
            endcase
            if file_exist(data(0)) and ~iris then begin ; local file, assume heterogenous per image[0]
               read_sdo,data(0),iiiz
               index=add_tag(index,iiiz.naxis1,'naxis1')
               index=add_tag(index,iiiz.naxis2,'naxis2')
            endif else begin 
               if iris then begin 
                  fuv=(gt_tagval(index,/instrume,missing='') eq 'FUV')
                  index=add_tag(index,intarr(n_elements(index))+2072 * (fuv+1),'naxis1')
                  index=add_tag(index,intarr(n_elements(index))+1096,'naxis2')
               endif else begin 
                  index=add_tag(index,4096,'naxis1') ; historical native sdo assumed, aia or hmi numbers
                  index=add_tag(index,4096,'naxis2')
               endelse
            endelse
         endcase
      endcase
   endif
endif ; end if DATA parm
jsoc_tags='count,status,runtime'
if required_tags(index,jsoc_tags) and keyword_set(no_jsoc_tags) then begin 
   index=str_subset(index,jsoc_tags,/exclude)
endif

count=n_elements(index)*data_chk(index,/struct)
if data_chk(data,/string) then count=count*(data[0] ne '')



return
end
