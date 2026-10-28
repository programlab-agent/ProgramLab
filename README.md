# ProgramLab

Training environments for agents that rebuild real programs. Each of the 1,261 tasks gives the agent a
compiled program it can run but not read, plus its documentation, and asks it to write the whole program
again. Hidden behavioral tests score the result. Tasks use the [ProgramBench](https://programbench.com)
format, so the official evaluator scores them unchanged.

[Blog](https://programlab.blog/) · [Dataset](https://huggingface.co/datasets/Program-Lab/ProgramLab) · [Tests](https://huggingface.co/datasets/Program-Lab/ProgramLab-Tests)

## Try a task

Every task is a public image. This drops you into the cleanroom of `mkcert`, offline:

```bash
docker run -it --rm --network none --user 1000:1000 ghcr.io/programlab-agent/programlab:filosottile__mkcert.2a46726
```

Inside, `/workspace/executable` is the reference program (execute-only) and `/workspace` holds its documentation.
The agent's job is to write a program plus a `compile.sh` that builds it.

## Evaluate a run

```bash
pip install programbench==1.2.4
git clone https://github.com/programlab-agent/ProgramLab
bash ProgramLab/setup.sh            # all tasks; or a regex, e.g. 'mkcert|jless'
export PROGRAMBENCH_DOCKER_ORG=ghcr.io/programlab-agent
export PROGRAMBENCH_HF_REPO=Program-Lab/ProgramLab-Tests
programbench eval my-run
```

`setup.sh` installs the task definitions into ProgramBench and pulls the images you selected.
A run directory holds one `submission.tar.gz` per task, as in
[ProgramBench](https://github.com/facebookresearch/ProgramBench/blob/main/docs/README.md):

```
my-run/
├── filosottile__mkcert.2a46726/submission.tar.gz
└── pauljuliusmartinez__jless.21dd610/submission.tar.gz
```

Tests are downloaded on demand for the tasks you score. `PROGRAMBENCH_DOCKER_ORG` is global, so a shell set up
for ProgramLab does not also score upstream ProgramBench tasks.

## Pick tasks for training

[`instances.jsonl`](https://huggingface.co/datasets/Program-Lab/ProgramLab/blob/main/instances.jsonl) has one row per
task with its language, difficulty, size, test count, coverage, and image:

```python
import json
tasks = [json.loads(line) for line in open("instances.jsonl")]
easy_rust = [t["instance_id"] for t in tasks if t["difficulty"] == "easy" and t["language"] == "rs"]
```

## Rebuild the images

The Docker build context of every task and the base image are in `build/` of the dataset, if you would
rather not pull from GHCR.

## Citation

```bibtex
@misc{programlab2026,
  title={ProgramLab: Train single and multi agents to rebuild programs},
  author={Yao Tang and Daixuan Cheng and Li Dong and Zhihao Zhan and Shaohan Huang and Jiatao Gu and Furu Wei},
  howpublished={Blog Post},
  url={https://programlab.blog/},
  year={2026}
}
```
