from fastapi import Depends, HTTPException, status
from app.auth.jwt_handler import get_current_user

def admin_required(current_user: dict = Depends(get_current_user)):
    """Dependency that ensures the current user has admin role.
    Raises 403 Forbidden if the user is not an admin.
    """
    if current_user.get('role') != 'admin':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail='Admin privileges required',
        )
    return current_user
