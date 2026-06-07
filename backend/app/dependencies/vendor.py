from fastapi import Depends, HTTPException, status
from app.auth.jwt_handler import get_current_user


def vendor_required(current_user: dict = Depends(get_current_user)):
    """Dependency that ensures the current user has vendor role.
    Raises 403 Forbidden if the user is not a vendor.
    """
    if current_user.get('role') != 'vendor':
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail='Vendor privileges required',
        )
    return current_user
