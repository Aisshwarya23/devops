import pytest
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))

def test_imports():
    import pandas as pd
    import numpy as np
    assert pd is not None
    assert np is not None

def test_model_file_exists():
    assert os.path.exists("anomaly_model.pkl"), "anomaly_model.pkl missing"

def test_sample_logs_readable():
    import pandas as pd
    df = pd.read_csv("sample_logs.csv")
    assert len(df) > 0

def test_prometheus_counter():
    from prometheus_client import Counter, REGISTRY
    c = Counter('test_ci_counter_total2', 'CI test')
    c.inc()
    assert REGISTRY.get_sample_value('test_ci_counter_total2_total') == 1.0