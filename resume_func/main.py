from pprint import pprint
from googleapiclient import discovery
import datetime
import os

def arr_resume_func(request):
    compute = discovery.build('compute', 'v1')
    # Project ID for this request.
    PROJECT_ID = os.environ['PROJECT_ID']
    oscaraccounts=os.environ['SERVICE_ACCOUNT']
    tagsitems=os.environ['TAGITEMS']
    machinetype=[ "n2-standard-16" , "n2-standard-8" ]
    days=["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]

    arrresume_func = []
    request = compute.instances().aggregatedList(project=PROJECT_ID)
    while request is not None:
        now = datetime.datetime.utcnow()
        dayNumber=now.weekday()
        print ("Today:" + days[dayNumber])
        response = request.execute()
        instance = response.get('items', {})
        for instance in instance.values():
          for ins in instance.get('instances', []):
            try:
                if ( ins['labels']['resume'] == 'true' and int(ins['labels']['resume-time-utc']) == int(now.hour) ):
                        if tagsitems in ins['tags']['items']:
                            for s in ins['serviceAccounts']:
                                if s['email'] == oscaraccounts:
                                    if ins[ 'machineType'].split("/")[-1] in machinetype:
                                        try:
                                            if  days[dayNumber].lower() not in ins['labels']['resume-week-day-ignore']:
                                                arrresume_func.append(str(ins['name']) + ":" + str(ins['zone'].split("/")[-1]  ))
                                        except:
                                            arrresume_func.append(str(ins['name']) + ":" + str(ins['zone'].split("/")[-1]  ))
            except:
                continue
        request = compute.instances().aggregatedList_next(previous_request=request, previous_response=response)

    print ("Number of Instance to resume_func: Len is {} , Array is {}".format(len(arrresume_func), str(arrresume_func)))
    for machineresume_func in arrresume_func:
        result = compute.instances().resume_func(project=PROJECT_ID, zone=machineresume_func.split(":")[1], instance=machineresume_func.split(":")[0]).execute()
