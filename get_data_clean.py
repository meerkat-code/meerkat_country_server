import urllib2,base64,gnupg,datetime,StringIO,csv,os,subprocess

def get_form(url,form,username,password,encrypt):
    print form
    now=datetime.datetime.now()
    #download form
    subprocess.call('java -jar briefcase.jar --form_id %s --storage_directory /root/data --aggregate_url %s --odk_username %s --odk_password "%s" -f %s.csv -ed /root/data/ ;'%(form,url,username,password,form+"_tmp"),shell=True)
    #Store encrypted verions of form
    print 
    subprocess.call("gpg --output %s --encrypt --recipient %s %s"%("encrypted/"+form+str(now.isoformat())+".gpg",encrypt,form+"_tmp.csv"),shell=True)
    #anonomise form
    in_file=open(form+"_tmp.csv","r")
    r=csv.DictReader(in_file)

    out_file=open(form+".csv","w")
    w=csv.DictReader(out_file)
    
    i=1
    for row in r:
        if i==1:
            out=csv.DictWriter(out_file,fix_header(r.fieldnames)+["_index"])
            out.writeheader()
        new_dict=fix_keys(row.copy())
#        print new_dict
        new_dict["_index"]=i
        if "pt./firstname" in new_dict:
            new_dict["pt./firstname"]=''
        if "pt./surname" in new_dict:
            new_dict["pt./surname"]=''
        if "pt./address" in new_dict:
            new_dict["pt./address"]=''
        if "pt./phone" in new_dict:
            new_dict["pt./phone"]=''
        if "pt./nationalid" in new_dict:
            new_dict["pt./nationalid"]=''
        out.writerow(new_dict)
        i+=1
    in_file.close()
    out_file.close()
    os.remove(form+"_tmp.csv")

def fix_header(h):
    new_h=[]
    for k in h:
        if k.find("-")!=-1:
            new_h.append(k.replace("-","/"))
        else:
            new_h.append(k)
    if "pregnancy" in new_h:
        new_h.remove("pregnancy")
        
    return new_h

def fix_keys(row):
    row.pop("pregnancy",None)
    row.pop(None,None)
    for k in row.keys():
        if k:
            if k.find("-")!=-1:
                row[k.replace("-","/")]=row.pop(k,None)
        
    return row
                    

forms=["jor_case","jor_alert","jor_register","jor_review"]
for f in forms:
    get_form("https://jor.emro.info",f,"ops","password","whodata@whodata.int")
