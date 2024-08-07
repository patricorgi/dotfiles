import os

import yaml

workdir = os.environ["MAJORANA"] + '/ganga'


def remove_jobs(*jobids):

    if not isinstance(jobids, list):
        jobids = [jobids]

    for jobid in jobids:
        try:
            j = jobs(jobid)
        except Exception as e:
            print(e, " skipping...")
            continue
        if j.status == "new":
            j.remove()
            continue
        j.force_status("failed", force=True)
        sjs = j.subjobs
        print(f"removing {len(sjs)} subjobs...")
        for sj in sjs:
            ofiles = sj.outputfiles.get(DiracFile)
            print(f"removing {len(ofiles)} output files...")
            for f in sj.outputfiles.get(DiracFile):
                if f.lfn:
                    f.remove()
        j.remove()


def resubmit_jobs(*jobids):

    if not isinstance(jobids, list):
        jobids = [jobids]

    for jobid in jobids:
        try:
            j = jobs(jobid)
        except Exception as e:
            print(e, " skipping...")
            continue
        sjs = j.subjobs.select(status="completing")
        for sj in sjs:
            sj.force_status("failed")
            sj.resubmit()
        sjs = j.subjobs.select(status="failed")
        for sj in sjs:
            sj.force_status("failed")
            sj.resubmit()


def print_outputs(jobid):
    outfiles = jobs(jobid).backend.getOutputDataAccessURLs()
    return outfiles


def save_outputs_to_yaml(*jobids):
    if not isinstance(jobids, list):
        jobids = [jobids]
    for jobid in jobids:
        try:
            j = jobs(jobid)
        except Exception as e:
            print(e, " skipping...")
            continue
        print("Working on job", jobid, "...")
        j = jobs(int(jobid))
        yfile = f"{workdir}/grid_files/{jobid}_{j.name}_{j.comment}.yaml"
        with open(yfile, "w") as f:
            file_lists = j.backend.getOutputDataAccessURLs()
            yaml.dump(file_lists, f)
