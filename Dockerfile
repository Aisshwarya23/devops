FROM python:3.11.5-slim

RUN useradd -m appuser

WORKDIR /home/appuser/app

# Copy requirements from cyber folder
COPY cyber/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copy full cyber folder
COPY cyber ./cyber

RUN chown -R appuser:appuser /home/appuser/app

USER appuser

EXPOSE 8501

CMD ["streamlit", "run", "cyber/dashboard.py", "--server.port=8501", "--server.address=0.0.0.0"]