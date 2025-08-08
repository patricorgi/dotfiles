import os
import subprocess

import yaml

workdir = os.environ["MAJORANA"] + '/ganga'


def is_iteratable(args):
    return isinstance(args, list) or isinstance(args, tuple)


def remove_jobs(*jobids):

    if not is_iteratable(jobids):
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


def resubmit_jobs(*jobids, statuses_to_resubmit=["failed", "completing"]):

    if not is_iteratable(jobids):
        jobids = [jobids]

    for jobid in jobids:
        print("working on", jobid)
        try:
            j = jobs(jobid)
        except Exception as e:
            print(e, " skipping...")
            continue
        for status in statuses_to_resubmit:
            sjs = j.subjobs.select(status=status)
            for sj in sjs:
                print("resubmitting", sj.id)
                sj.force_status("failed")
                sj.resubmit()


def print_outputs(jobid):
    outfiles = jobs(jobid).backend.getOutputDataAccessURLs()
    return outfiles


def save_outputs_to_yaml(*jobids):
    yfiles = []
    if not is_iteratable(jobids):
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
            print("Saving", len(file_lists), "files...")
            yaml.dump(file_lists, f)
        yfiles.append(yfile)
    return yfiles


def validate_tuple_file(filename: str, directory_list: list[str]) -> bool:
    # print("Validating", filename, "with TDirectory", *directory_list)
    # if not os.path.exists(filename):
    #     return False
    # try:
    #     print("Opening", filename)
    #     f = ROOT.TFile.Open(filename, "READ")
    #     for dir in directory_list:
    #         print("Checking", dir)
    #         d = f.Get(dir)
    #         if not isinstance(d, ROOT.TDirectory):
    #             print("TDirectory", dir, "does not exists in file", filename)
    #             del f
    #             return False
    # except OSError:
    #     return False
    # del f
    return True


def download_file(eos_path, out_dir, tdir):
    outfile = eos_path.split(os.environ["USER"] + "/")[-1].split(
        '/DVntuple')[0].replace("/", "_") + ".root"
    outpath = out_dir + "/" + outfile
    if validate_tuple_file(outpath, directory_list=[tdir]):
        return
    cmd = ['xrdcp', '--force', eos_path, outpath]
    print(cmd)
    subprocess.run(cmd)
    if not validate_tuple_file(outpath, directory_list=[tdir]):
        print("[WARNING] Failed to download", eos_path)
        with open(yfile.replace('.yaml', '-failed.yaml'), 'a') as f:
            f.write(f"xrdcp --force {eos_path} {outpath}")
            f.write("\n")
        if os.path.exists(outpath):
            print("Will remove", outpath)
            os.remove(outpath)
        sys.stdout.flush()


def download_files_in_yaml(yfile, output, tdir_must_exist="MyTuple"):
    import concurrent.futures
    from functools import partial

    print("Downloading tuples from", yfile)
    os.environ["X509_USER_PROXY"] = os.environ["HOME"] + "/.grid.proxy"
    outdir = os.environ["TUPLEROOT"] + "/" + output + "/" + os.path.splitext(
        os.path.basename(yfile))[0]
    tdir = tdir_must_exist
    print("Creating directory:", outdir)
    os.makedirs(outdir, exist_ok=True)
    with open(yfile, "r") as f:
        file_list = yaml.safe_load(f)

    partial_download_file = partial(download_file, out_dir=outdir, tdir=tdir)
    with concurrent.futures.ProcessPoolExecutor(max_workers=48) as exc:
        _ = list(exc.map(partial_download_file, file_list))


def download_files_in_yamls(yfiles, output, tdir_must_exist="MyTuple"):
    if not is_iteratable(yfiles):
        yfiles = [yfiles]
    for yfile in yfiles:
        download_files_in_yaml(yfile, output, tdir_must_exist)
