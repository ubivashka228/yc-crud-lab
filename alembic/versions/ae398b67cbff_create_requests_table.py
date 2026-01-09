"""create requests table

Revision ID: ae398b67cbff
Revises: ae135ca06781
Create Date: 2026-01-10 02:07:55.344554

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'ae398b67cbff'
down_revision: Union[str, Sequence[str], None] = 'ae135ca06781'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "requests",
        sa.Column("id", sa.Integer(), primary_key=True),
        sa.Column("subject", sa.String(length=255), nullable=False),
        sa.Column("body", sa.Text(), nullable=True),
        sa.Column("status", sa.String(length=32), nullable=False, server_default="new"),
        sa.Column("attachment_key", sa.String(length=1024), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False, server_default=sa.text("now()")),
    )
    op.create_index("ix_requests_created_at", "requests", ["created_at"])


def downgrade() -> None:
    op.drop_index("ix_requests_created_at", table_name="requests")
    op.drop_table("requests")