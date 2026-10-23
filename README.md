# Cloud Composer Training Labs

Hands-on labs for learning Apache Airflow on Google Cloud Composer, from a first DAG to custom operators and BigQuery data pipelines. I use these labs in my corporate GCP training sessions.

**Who it's for:** engineers new to Airflow or Cloud Composer, and data engineers moving pipelines to GCP.

**What you need:** a GCP project with billing enabled, Terraform, the `gcloud` CLI, and basic Python.

## What's inside

```
gcp-composer-training/
├── infra/            # Terraform: Composer API, service account, IAM roles, Composer 2 environment
├── dags/             # The lab DAGs (see the lab order below)
├── plugins/          # Custom operators used by the later labs
├── scripts/          # Generates a 1-million-row sample dataset (CSV and Parquet)
├── data/             # Input file for the dynamic DAG lab
└── sample.csv        # Small sample file for the GCS to BigQuery lab
```

## Lab order

The labs build on each other. Work through them in this order.

| # | DAG file | What it teaches |
|---|---|---|
| 1 | `simple_dag.py` | DAG structure, `BashOperator`, task dependencies |
| 2 | `branching_dag.py` | Choosing a path at run time with `BranchPythonOperator` |
| 3 | `advanced_dependencies_dag.py` | Fan-out and fan-in dependencies between tasks |
| 4 | `taskgroup_parallel_dag.py` | Grouping parallel tasks with `TaskGroup` |
| 5 | `dynamic_advanced_dag.py` | Generating tasks in a loop |
| 6 | `dynamic_dag_with_csv_input.py` | Generating one task per row of an input file |
| 7 | `custom_operator_dag.py` | Writing and using your own operator (`plugins/custom_operator.py`) |
| 8 | `api_operator_dag.py` | A custom operator that calls an external REST API (`plugins/api_operator.py`) |
| 9 | `gcs_bq_dag.py` | Loading a CSV from Cloud Storage into BigQuery, then querying it |
| 10 | `bigquery_large_data_pipeline_dag.py` | A partitioned BigQuery table loaded from Parquet, then transformed and checked |
| 11 | `etl_pipeline_dag.py` | An ETL pipeline combining batch files, Pub/Sub messages and BigQuery transformations |

## Setup

**1. Create the Composer environment.** Copy the example variables file and fill in your project ID and project number:

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

Creating a Composer environment usually takes 20 to 30 minutes.

**2. Find the environment's bucket.**

```bash
gcloud composer environments describe composer-training \
  --location us-central1 --format="value(config.dagGcsPrefix)"
```

**3. Upload the DAGs, plugins and data.**

```bash
BUCKET=gs://<your-composer-bucket>
gsutil cp dags/*.py    $BUCKET/dags/
gsutil cp plugins/*.py $BUCKET/plugins/
gsutil cp sample.csv data/input_data.csv $BUCKET/data/
```

**4. Generate the large dataset** for lab 10, then upload it.

```bash
pip install pandas numpy pyarrow
python scripts/generate_data.py
gsutil cp large_data.parquet $BUCKET/data/
```

**5. Open the Airflow UI** from the Composer page in the Cloud Console, then trigger the DAGs in lab order.

Before running labs 9 to 11, replace the placeholders in those DAG files (`<YOUR_COMPOSER_BUCKET>`, `<PROJECT_ID>`, `<DATASET_NAME>`, `<YOUR_BUCKET_NAME>`, `your-project-id`) with your own values, and create the BigQuery dataset.

## Clean up

Composer environments are billed while they run, so delete it when you finish:

```bash
cd infra
terraform destroy
```

The Composer API is left enabled on purpose (`disable_on_destroy = false`), because disabling it can break other Composer environments in the project.

## Author

Ravi Kulkarni: cloud and DevOps trainer and engineer. [LinkedIn](https://www.linkedin.com/in/ravisharadkulkarni)
