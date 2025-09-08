"""
Tests for database models
"""
import pytest
from datetime import datetime
from app.models.rate import Rate
from app.models.usage_event import UsageEvent

def test_rate_model():
    """Test Rate model creation"""
    rate = Rate(
        code="USD",
        name="US Dollar",
        value=90.91,
        updated_at=datetime.now()
    )
    assert rate.code == "USD"
    assert rate.name == "US Dollar"
    assert rate.value == 90.91
    assert rate.updated_at is not None

def test_usage_event_model():
    """Test UsageEvent model creation"""
    import uuid
    event = UsageEvent(
        device_id=uuid.uuid4(),
        event_name="app_open",
        payload={"test": "data"}
    )
    assert event.device_id is not None
    assert event.event_name == "app_open"
    assert event.payload == {"test": "data"}
    # created_at is set by database, so we just check it exists
    assert hasattr(event, 'created_at')
