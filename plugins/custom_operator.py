from airflow.models import BaseOperator

class MyCustomOperator(BaseOperator):
    def __init__(self, message: str, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.message = message  # Custom parameter

    def execute(self, context):
        print(f"Custom Operator Message: {self.message}")
