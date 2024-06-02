FROM public.ecr.aws/lambda/python:3.12

COPY requirements.txt ${LAMBDA_TASK_ROOT}

RUN python3.12 -m pip install -r requirements.txt -t .

COPY src/* ${LAMBDA_TASK_ROOT} 

CMD ["lambda_function.lambda_handler"]
