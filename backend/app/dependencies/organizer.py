from fastapi import Depends, HTTPException, status
from app.auth.jwt_handler import get_current_user

def organizer_required(current_user: dict = Depends(get_current_user)):
    """Allow only users with the organizer role."""
    if current_user.get("role") != "organizer":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Organizer privileges required",
        )
    return current_user
