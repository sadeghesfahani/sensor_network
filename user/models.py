from django.contrib.auth.models import AbstractUser
from django.db import models

from user.enums import BuildingFramework, BuildingOccupancy


# Create your models here.



class User(AbstractUser):
    phone = models.CharField(max_length=20, blank=True)
    email = models.EmailField(blank=True, null=True)
    token = models.CharField(max_length=255, blank=True)
    is_superuser = models.BooleanField(default=False)
    building_construction_year = models.CharField(max_length=4, blank=True)
    framework_x = models.IntegerField(blank=True, choices=[(e.value, e.name) for e in BuildingFramework])
    framework_y = models.IntegerField(blank=True, choices=[(e.value, e.name) for e in BuildingFramework])
    occupancy = models.IntegerField(blank=True, choices=[(e.value, e.name) for e in BuildingOccupancy])
