from django.contrib.auth.models import AbstractUser
from django.db import models

from user.enums import BuildingFramework, BuildingOccupancy


# Create your models here.

class Framework(models.Model):
    name = models.CharField(max_length=120)
    universal_id = models.SmallIntegerField(choices=[(e.value, e.name) for e in BuildingFramework], unique=True)
    description = models.TextField(max_length=120)
    image = models.ImageField(upload_to='frameworks', null=True, blank=True)

    def __str__(self):
        return self.name


class Occupancy(models.Model):
    name = models.CharField(max_length=120)
    universal_id = models.SmallIntegerField(choices=[(e.value, e.name) for e in BuildingOccupancy], unique=True)
    description = models.TextField(max_length=120)
    image = models.ImageField(upload_to='occupancies', null=True, blank=True)

    def __str__(self):
        return self.name


class User(AbstractUser):
    phone = models.CharField(max_length=20, blank=True)
    email = models.EmailField(blank=False, null=False, unique=True)
    token = models.CharField(max_length=255, blank=True)
    is_superuser = models.BooleanField(default=False)
    building_construction_year = models.CharField(max_length=4, blank=True)
    framework_x = models.ForeignKey(Framework, on_delete=models.CASCADE)
    framework_y = models.ForeignKey(Framework, on_delete=models.CASCADE)
    occupancy = models.ForeignKey(Occupancy, on_delete=models.CASCADE)
