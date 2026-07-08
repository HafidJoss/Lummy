from pydantic import BaseModel
from typing import List

class LeaderboardEntry(BaseModel):
    rank_position: int
    user_id: str
    display_name: str
    title: str
    avatar_url: str | None = None
    xp_total: int
    level_id: int
    accuracy_global: float

class LeaderboardResponse(BaseModel):
    page: int
    total_pages: int
    items: List[LeaderboardEntry]
    
class MyLeaderboardPosition(BaseModel):
    rank_position: int
    xp_total: int
    level_id: int
