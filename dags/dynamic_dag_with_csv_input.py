import csv
import os
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime

# Define the CSV input file path
# On Cloud Composer, files in the bucket's data/ folder appear at this path
file_path = "/home/airflow/gcs/data/input_data.csv"

# Function to read the input file
def read_csv_file(file_path, **kwargs):
    if not os.path.exists(file_path):
        print(f"Input file not found: {file_path}. Upload data/input_data.csv to the Composer bucket.")
        return []
    with open(file_path, 'r') as file:
        csv_reader = csv.DictReader(file)
        rows = [row for row in csv_reader]
        print(f"Loaded data: {rows}")
        return rows

# Function to process each row dynamically
def process_row(row, **kwargs):
    print(f"Processing row: {row}")

# Define the DAG
with DAG(
    dag_id="dynamic_dag_with_csv_input",
    schedule="@daily",
    start_date=datetime(2025, 1, 1),
    catchup=False
) as dag:

    # Dynamic task generation
    def create_tasks(file_path):
        rows = read_csv_file(file_path)
        dynamic_tasks = []
        for row in rows:
            task = PythonOperator(
                task_id=f"process_{row['id']}",
                python_callable=process_row,
                op_args=[row],
                dag=dag
            )
            dynamic_tasks.append(task)
        return dynamic_tasks

    # Generate dynamic tasks based on the CSV input
    dynamic_tasks = create_tasks(file_path)

    # Set sequential dependencies
    for i in range(len(dynamic_tasks) - 1):
        dynamic_tasks[i] >> dynamic_tasks[i + 1]
